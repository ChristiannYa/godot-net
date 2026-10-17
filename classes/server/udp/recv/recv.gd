class_name UdpRecvr

const _BITS_LEN := 8

var _peer: PacketPeerUDP
var _rel: UdpReliable
var _state: UdpState

var _data: PktRecvData = PktRecvData.new()
var _ack: PktRecvAck = PktRecvAck.new(_rel)
var _snapshot: PktRecvSnapshot = PktRecvSnapshot.new()

## session id -> sequence number
var _last_seq: Dictionary = {}


func _init(
	udp_peer: PacketPeerUDP,
	rel: UdpReliable,
	net_state: UdpState,
):
	_peer = udp_peer
	_rel = rel
	_state = net_state


func recv(pkt: PackedByteArray):
	## Too short to hold the header
	if pkt.size() < 2:
		return

	match pkt[0]:
		UdpCodec.PKT_ACK:
			_ack.recv(pkt)

		UdpCodec.PKT_DATA:
			_data.recv(pkt, _handler)

		UdpCodec.PKT_SNAPSHOT:
			_snapshot.recv(pkt, _handler)


## `pkt`: field name -> value
func _handler(raw_pkt: Dictionary, is_sync: bool):
	var sid: int = raw_pkt.get("DevSessionId")
	if sid == null:
		return

	if raw_pkt.has("DevSequence"):
		var seq: int = raw_pkt["DevSequence"]
		if !_is_seq_new(sid, seq):
			return  # Dropped: stale/out-of-order packet
		_last_seq[sid] = seq

	if raw_pkt.has("DevPacketId"):
		var pkt_id: int = raw_pkt["DevPacketId"]
		UdpClient.sender.def(UdpAck.encode_ack(pkt_id))
		if _rel.is_pkt_seen(pkt_id):
			return  # No need to re-process packet

	if raw_pkt.has("DevIsNewPlayer"):
		SignalHub.emit_player_sid(sid)

	if !_state.players().has(sid):
		_state.reg_player(sid, is_sync)

	for field_name: String in raw_pkt:
		if !field_name.begins_with("Dev"):
			_state.save_field(sid, field_name, raw_pkt[field_name])


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
