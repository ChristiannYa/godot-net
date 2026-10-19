class_name PktRecvSnapshot


func recv(raw_pkt: PackedByteArray):
	if UdpClient.state.ingest_ss(raw_pkt, UTime.now_s()):
		SignalHub.emit_players_updated()
