class_name PktRecvr

const _BITS_LEN := 8

var _udp_peer: PacketPeerUDP
var _rel: NetReliable
var _net_state: NetState

var ack: PktRecvAck
var data: PktRecvData
var snapshot: PktRecvSnapshot

## session id -> sequence number
var _last_seq: Dictionary = {}


func _init(
	udp_peer: PacketPeerUDP,
	rel: NetReliable,
	net_state: NetState,
):
	_udp_peer = udp_peer
	_rel = rel
	_net_state = net_state

	data = PktRecvData.new(net_state, _handler)
	ack = PktRecvAck.new(rel)
	snapshot = PktRecvSnapshot.new(net_state, _handler)


## `pkt`: field name -> value
func _handler(raw_pkt: Dictionary, is_sync: bool):
	var sid: int = raw_pkt.get("DevSessionId")

	if raw_pkt.has("DevSequence"):
		var seq: int = raw_pkt["DevSequence"]
		if !_is_seq_new(sid, seq):
			return  # Dropped: stale/out-of-order packet
		_last_seq[sid] = seq

	if raw_pkt.has("DevPacketId"):
		var pkt_id: int = raw_pkt["DevPacketId"]
		_udp_peer.put_packet(UdpAck.encode_ack(pkt_id))
		if _rel.is_pkt_seen(pkt_id):
			return  # No need to re-process packet

	if raw_pkt.has("DevIsNewPlayer"):
		SignalHub.emit_player_sid(sid)

	_net_state.reg_player(sid, is_sync)

	for field_name: String in raw_pkt:
		if !field_name.begins_with("Dev"):
			_net_state.save_field(sid, field_name, raw_pkt[field_name])


## Returns true if `seq` is more recent than `last_seq`, treating both as a
## circular counter that wraps at 2^`_BITS_LEN`.
## This correctly handles wraparound (e.g. 0 counts as newer than 255) while
## still rejecting genuinely stale/out-of-order packets.
func _is_seq_new(sid: int, seq: int) -> bool:
	if !_last_seq.has(sid):
		return true  # First ever packet from this player
	var last_seq: int = _last_seq[sid]

	var bits_max: int = 1 << _BITS_LEN
	var diff: int = (seq - last_seq + bits_max) % bits_max
	return diff != 0 and diff < (bits_max >> 1)
