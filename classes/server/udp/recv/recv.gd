class_name PktRecvr

var _udp_peer: PacketPeerUDP
var _rel: NetReliable
var _state: NetState

var ack: PktRecvAck
var data: PktRecvData
var snapshot: PktRecvSnapshot


func _init(
	udp_peer: PacketPeerUDP,
	rel: NetReliable,
	state: NetState,
):
	_udp_peer = udp_peer
	_rel = rel
	_state = state

	data = PktRecvData.new(state, _handler)
	ack = PktRecvAck.new(rel)
	snapshot = PktRecvSnapshot.new(state, _handler)


## `pkt`: field name -> value
func _handler(raw_pkt: Dictionary, is_sync: bool):
	var sid: int = raw_pkt.get("DevSessionId")

	# Dropped: stale/out-of-order packet
	if !_state.accept_seq(sid, raw_pkt):
		return

	if raw_pkt.has("DevPacketId"):
		var pkt_id: int = raw_pkt["DevPacketId"]
		_udp_peer.put_packet(UdpAck.encode_ack(pkt_id))
		if _rel.is_pkt_seen(pkt_id):
			return  # No need to re-process packet

	if raw_pkt.has("DevIsNewPlayer"):
		SignalHub.emit_player_sid(sid)

	_state.reg_player(sid, is_sync)

	for field_name: String in raw_pkt:
		if !field_name.begins_with("Dev"):
			_state.save_field(sid, field_name, raw_pkt[field_name])
