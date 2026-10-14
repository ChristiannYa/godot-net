class_name PktRecvSnapshot

var _clock := ServerClock.new()
var _net_state: NetState
var _handler: Callable


func _init(net_sate: NetState, handler: Callable):
	_net_state = net_sate
	_handler = handler


func recv(raw_pkt: PackedByteArray):
	var ss: Dictionary = UdpClient.udp_codec.decode_snapshot(raw_pkt)
	if ss.is_empty():
		return

	var now_s := UTime.now_s()
	if !_clock.accept(ss["tick"], now_s):
		return

	for pkt: Dictionary in ss["records"]:
		_handler.call(pkt, true)
	SignalHub.emit_player_snapshot_sig(
		_net_state.players(), _clock.cur_ss_time()
	)

	# A controlled player is also moved by this signal. Skipping it would
	# freeze the player
	SignalHub.emit_player_states_live(_net_state.players())
