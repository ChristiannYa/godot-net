extends Node

var _udp_peer := PacketPeerUDP.new()
var udp_codec := UdpCodec.create()

var _state := NetState.new()
var _rel := NetReliable.new()

func _ready():
	_udp_peer.bind(0)
	_udp_peer.set_dest_address("10.0.0.4", 34254)
	self.send_input("DevPing", 1)

func _process(_delta: float):
	while _udp_peer.get_available_packet_count() > 0:
		var pkt = _udp_peer.get_packet()

		## Too short to hold the header
		if pkt.size() < 2: continue

		match pkt[0]:
			UdpCodec.PKT_ACK: _handle_ack_pkt(pkt)
			UdpCodec.PKT_DATA: _handle_data_pkt(pkt)

	_tick_rel()

func _handle_ack_pkt(raw_pkt: PackedByteArray):
	var id: int = UdpAck.decode_ack(raw_pkt)
	if id != -1: _rel.handle_ack(id)

func _handle_data_pkt(raw_pkt: PackedByteArray):
	match raw_pkt[1]:
		UdpCodec.DEC_SINGLE:
			_handle_pkt(udp_codec.decode(raw_pkt), false)
		UdpCodec.DEC_BATCH:
			var records: Array = udp_codec.decode_batch(raw_pkt)
			for pkt in records: _handle_pkt(pkt, true)

	SignalHub.emit_player_states_live(_state.player_states())

## `pkt`: field name -> value
func _handle_pkt(pkt: Dictionary, is_sync: bool):
	print("[net_client, _handle_pkt] sid=%s, dev_pkt_id=%s" % [pkt.get("DevSessionId"), pkt.get("DevPacketId")])

	var sid: int = pkt.get("DevSessionId")

	# Dropped: stale/out-of-order packet
	if !_state.accept_seq(sid, pkt): return 

	if pkt.has("DevPacketId"):
		var pkt_id: int = pkt["DevPacketId"]
		_udp_peer.put_packet(UdpAck.encode_ack(pkt_id))
		if _rel.is_pkt_seen(pkt_id): return # No need to re-process packet

	if pkt.has("DevIsNewPlayer"): SignalHub.player_sid_sig.emit(sid)

	_state.reg_player(sid, is_sync)

	for field_name: String in pkt:
		if !field_name.begins_with("Dev"):
			_state.save_field(sid, field_name, pkt[field_name])

func _tick_rel():
	for bytes: PackedByteArray in _rel.tick():
		_udp_peer.put_packet(bytes)

func is_synced(sid: int) -> bool: return _state.is_synced(sid)

func player_states() -> Dictionary: return _state.player_states()

func send_input(field_name: String, value: int):
	var pkt = udp_codec.encode({field_name: value})
	_udp_peer.put_packet(pkt)

func send_input_rel(field_name: String, val: int):
	var pkt := _rel.send({field_name: val}, udp_codec.encode)
	_udp_peer.put_packet(pkt)
