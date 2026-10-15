class_name PktRecvData


func recv(raw_pkt: PackedByteArray, handler: Callable):
	match raw_pkt[1]:
		UdpCodec.DEC_SINGLE:
			handler.call(UdpClient.udp_codec.decode(raw_pkt), false)
		UdpCodec.DEC_BATCH:
			var records: Array = UdpClient.udp_codec.decode_batch(raw_pkt)
			for pkt in records:
				handler.call(pkt, true)

	SignalHub.emit_player_states_live(UdpClient.player_states())
