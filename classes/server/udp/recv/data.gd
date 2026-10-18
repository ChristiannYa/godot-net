class_name PktRecvData


func recv(raw_pkt: PackedByteArray, handler: Callable):
	match raw_pkt[1]:
		UdpCodec.DEC_SINGLE:
			handler.call(UdpClient.codec.decode(raw_pkt), false)
		UdpCodec.DEC_BATCH:
			var records: Array = UdpClient.codec.decode_batch(raw_pkt)
			for pkt in records:
				handler.call(pkt, true)

	UdpClient.players.ingest_data(raw_pkt)
	SignalHub.emit_player_states_live(UdpClient.player_states())
