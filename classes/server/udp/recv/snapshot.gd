class_name PktRecvSnapshot

var _clock := ServerClock.new()


func recv(raw_pkt: PackedByteArray, handler: Callable):
	var ss: Dictionary = UdpClient.codec.decode_dev_snapshot(raw_pkt)
	if ss.is_empty():
		return

	var now_s := UTime.now_s()
	if !_clock.accept(ss["tick"], now_s):
		return

	for pkt: Dictionary in ss["records"]:
		handler.call(pkt)

	UdpClient.players.ingest_ss(raw_pkt, _clock.cur_ss_time())
	SignalHub.emit_players_updated()
