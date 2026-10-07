class_name PacketHandler

var _udp_peer: PacketPeerUDP
var _udp_codec: UdpCodec
var _state: NetState
var _rel: NetReliable

func _init(
	udp_peer: PacketPeerUDP,
	udp_codec: UdpCodec, 
	state: NetState, 
	rel: NetReliable, 
):
	_udp_peer = udp_peer
	_udp_codec = udp_codec
	_state = state
	_rel = rel

func ack(raw_pkt: PackedByteArray):
	var id: int = UdpAck.decode_ack(raw_pkt)
	if id != -1: _rel.handle_ack(id)

func data(raw_pkt: PackedByteArray):
	match raw_pkt[1]:
		UdpCodec.DEC_SINGLE:
			_handle_pkt(_udp_codec.decode(raw_pkt), false)
		UdpCodec.DEC_BATCH:
			var records: Array = _udp_codec.decode_batch(raw_pkt)
			for pkt in records: _handle_pkt(pkt, true)

	var player_states_capture = _state.player_states()
	SignalHub.emit_player_states_live(player_states_capture)

## `pkt`: field name -> value
func _handle_pkt(pkt: Dictionary, is_sync: bool):
	var sid: int = pkt.get("DevSessionId")

	# Dropped: stale/out-of-order packet
	if !_state.accept_seq(sid, pkt): return 

	if pkt.has("DevPacketId"):
		var pkt_id: int = pkt["DevPacketId"]
		_udp_peer.put_packet(UdpAck.encode_ack(pkt_id))
		if _rel.is_pkt_seen(pkt_id): return # No need to re-process packet

	if pkt.has("DevIsNewPlayer"): SignalHub.emit_player_sid(sid)

	_state.reg_player(sid, is_sync)

	for field_name: String in pkt:
		if !field_name.begins_with("Dev"):
			_state.save_field(sid, field_name, pkt[field_name])
