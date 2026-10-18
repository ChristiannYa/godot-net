class_name PktRecvData


func recv(raw_pkt: PackedByteArray, handler: Callable):
	match raw_pkt[1]:
		UdpCodec.DEC_SINGLE:
			handler.call(UdpClient.codec.decode(raw_pkt))
		UdpCodec.DEC_BATCH:
			var records: Array = UdpClient.codec.decode_batch(raw_pkt)
			for pkt in records:
				handler.call(pkt)

	UdpClient.players.ingest_data(raw_pkt)
	SignalHub.emit_players_updated()
