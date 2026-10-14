extends Node

var _udp_peer := PacketPeerUDP.new()
var udp_codec := UdpCodec.create()

var _state := NetState.new()
var _rel := NetReliable.new()

var _pkt_rcvr := PktRecvr.new(_udp_peer, _rel, _state)

var _oneshot_field_cts: OneShot = OneShot.new()

# If the counter lived on the player node and that node were ever be freed and
# recreated while the session continued, it would restart at 0 and the server
# would drop everything as stale
var _intent_seq := 0


func _ready():
	_udp_peer.bind(0)
	_udp_peer.set_dest_address("10.0.0.4", 34254)
	self.send_input("DevPing", 1)


func _process(_delta: float):
	while _udp_peer.get_available_packet_count() > 0:
		var pkt = _udp_peer.get_packet()

		## Too short to hold the header
		if pkt.size() < 2:
			continue

		match pkt[0]:
			UdpCodec.PKT_ACK:
				_pkt_rcvr.ack.recv(pkt)
			UdpCodec.PKT_DATA:
				_pkt_rcvr.data.recv(pkt)
			UdpCodec.PKT_SNAPSHOT:
				_pkt_rcvr.snapshot.recv(pkt)

	_tick_rel()


func _tick_rel():
	for bytes: PackedByteArray in _rel.tick():
		_udp_peer.put_packet(bytes)


func send_input(field_name: String, value: int):
	var pkt = udp_codec.encode({field_name: value})
	_udp_peer.put_packet(pkt)


func send_input_rel(field_name: String, val: int):
	var pkt := _rel.send_input({field_name: val}, udp_codec.encode)
	_udp_peer.put_packet(pkt)


func send_intent(mv: Vector2, yaw: float):
	var jump_ct := _oneshot_field_cts.ct("jump")
	if jump_ct == null:
		return

	var pkt := udp_codec.encode_intent(
		_intent_seq, mv.x, mv.y, yaw, false, jump_ct
	)
	_udp_peer.put_packet(pkt)

	# 0xFF wraps the counter at 256 so it fits the protocol's seq 8-bit counter
	_intent_seq = (_intent_seq + 1) & 0xFF


func reg_oneshot(field: String):
	_oneshot_field_cts.reg(field)


func is_synced(sid: int) -> bool:
	return _state.is_synced(sid)


func player_states() -> Dictionary:
	return _state.player_states()
