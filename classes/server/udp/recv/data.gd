class_name PktRecvData

const _BITS_LEN := 8

var _rel: UdpReliable


func _init(rel: UdpReliable):
	_rel = rel


## session id -> sequence number
var _last_seq: Dictionary = {}


func recv(raw_pkt: PackedByteArray):
	if raw_pkt[1] == UdpCodec.DEC_SINGLE:
		if !_handle_dev(raw_pkt):
			return

	UdpClient.players.ingest_data(raw_pkt)
	SignalHub.emit_players_updated()


## Returns `false` if no sid, staleness, or duplicate ack
func _handle_dev(raw_pkt: PackedByteArray):
	var dev = UdpClient.codec.decode_dev(raw_pkt)

	var sid: int = dev.get("DevSessionId", -1)
	if sid == -1:
		return false

	if dev.has("DevSequence"):
		var seq: int = dev["DevSequence"]
		if !_is_seq_new(sid, seq):
			return false  # Dropped: stale/out-of-order packet
		_last_seq[sid] = seq

	if dev.has("DevPacketId"):
		var pkt_id: int = dev["DevPacketId"]
		UdpClient.sender.def(UdpAck.encode_ack(pkt_id))
		if _rel.is_pkt_seen(pkt_id):
			return false  # No need to re-process packet

	return true


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
