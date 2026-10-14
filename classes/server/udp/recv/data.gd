class_name PktRecvData

var _handler: Callable
var _net_state: NetState


func _init(net_state: NetState, handler: Callable):
	_net_state = net_state
	_handler = handler


func recv(raw_pkt: PackedByteArray):
	match raw_pkt[1]:
		UdpCodec.DEC_SINGLE:
			_handler.call(UdpSkt.udp_codec.decode(raw_pkt), false)
		UdpCodec.DEC_BATCH:
			var records: Array = UdpSkt.udp_codec.decode_batch(raw_pkt)
			for pkt in records:
				_handler.call(pkt, true)

	SignalHub.emit_player_states_live(_net_state.player_states())
