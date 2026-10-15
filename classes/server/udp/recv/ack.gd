class_name PktRecvAck

var _rel: UdpReliable


func _init(rel: UdpReliable):
	_rel = rel


func recv(raw_pkt: PackedByteArray):
	var id: int = UdpAck.decode_ack(raw_pkt)
	if id != -1:
		_rel.handle_ack(id)
