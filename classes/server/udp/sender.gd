class_name UdpSender

var _peer: PacketPeerUDP
var _rel: NetReliable
var _oneshot_cts: OneShot


func _init(peer_: PacketPeerUDP, rel_: NetReliable, oneshot_cts_: OneShot):
	_peer = peer_
	_rel = rel_
	_oneshot_cts = oneshot_cts_


# If the counter lived on the player node and that node were ever be freed and
# recreated while the session continued, it would restart at 0 and the server
# would drop everything as stale
var _intent_seq := 0


func def(field_name: String, value: int):
	var pkt = UdpClient.udp_codec.encode({field_name: value})
	_peer.put_packet(pkt)


func rel(field_name: String, val: int):
	var pkt := _rel.send_input({field_name: val}, UdpClient.udp_codec.encode)
	_peer.put_packet(pkt)


func due_rel():
	for bytes: PackedByteArray in _rel.tick():
		_peer.put_packet(bytes)


func intent(mv: Vector2, yaw: float, is_crouching: bool):
	var jump_ct := _oneshot_cts.ct("jump")
	if jump_ct == null:
		return

	var pkt := UdpClient.udp_codec.encode_intent(
		_intent_seq, mv.x, mv.y, yaw, is_crouching, jump_ct
	)
	_peer.put_packet(pkt)

	# 0xFF wraps the counter at 256 so it fits the protocol's seq 8-bit counter
	_intent_seq = (_intent_seq + 1) & 0xFF
