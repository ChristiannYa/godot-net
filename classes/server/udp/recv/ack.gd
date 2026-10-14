class_name PktRecvAck

var _rel: NetReliable


func _init(rel: NetReliable):
	_rel = rel


func recv(raw_pkt: PackedByteArray):
	var id: int = UdpAck.decode_ack(raw_pkt)
	if id != -1:
		_rel.handle_ack(id)
