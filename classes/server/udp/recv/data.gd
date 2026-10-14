class_name PktRecvData

var _handler: Callable


func _init(handler: Callable):
	_handler = handler


func recv(raw_pkt: PackedByteArray):
	match raw_pkt[1]:
		UdpCodec.DEC_SINGLE:
			_handler.call(UdpClient.udp_codec.decode(raw_pkt), false)
		UdpCodec.DEC_BATCH:
			var records: Array = UdpClient.udp_codec.decode_batch(raw_pkt)
			for pkt in records:
				_handler.call(pkt, true)

	SignalHub.emit_player_states_live(UdpClient.player_states())
