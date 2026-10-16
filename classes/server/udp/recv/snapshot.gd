class_name PktRecvSnapshot

var _clock := ServerClock.new()


func recv(raw_pkt: PackedByteArray, handler: Callable):
	var ss: Dictionary = UdpClient.codec.decode_snapshot(raw_pkt)
	if ss.is_empty():
		return

	var now_s := UTime.now_s()
	if !_clock.accept(ss["tick"], now_s):
		return

	for pkt: Dictionary in ss["records"]:
		handler.call(pkt, true)

	UdpClient.poses.ingest_snapshot(raw_pkt, _clock.cur_ss_time())

	# A controlled player is also moved by this signal. Skipping it would
	# freeze the player
	SignalHub.emit_player_states_live(UdpClient.player_states())
