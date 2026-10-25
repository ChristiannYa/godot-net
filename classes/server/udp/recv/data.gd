class_name PktRecvData

var _rel: UdpReliable


func _init(rel: UdpReliable):
	_rel = rel


func recv(raw_pkt: PackedByteArray):
	if raw_pkt[1] == UdpCodec.DEC_SINGLE:
		if !_handle_dev(raw_pkt):
			return

	UdpClient.players.ingest_data(raw_pkt)
	SignalHub.emit_players_updated()


## Returns `false` if no sid or duplicate ack
func _handle_dev(raw_pkt: PackedByteArray):
	var dev = UdpClient.codec.decode_dev(raw_pkt)

	var sid: int = dev.get("DevSessionId", -1)
	if sid == -1:
		return false

	if dev.has("DevPacketId"):
		var pkt_id: int = dev["DevPacketId"]
		UdpClient.sender.def(UdpAck.encode_ack(pkt_id))
		if _rel.is_pkt_seen(pkt_id):
			return false  # No need to re-process packet

	return true
