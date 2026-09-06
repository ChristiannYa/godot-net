extends Node

var _peer := PacketPeerUDP.new()
var _schema := GdPacketSchema.create()

func _ready():
	_peer.bind(0)
	_peer.set_dest_address("127.0.0.1", 34254)

func send_input(field_name: String, value: int):
	var packet = _schema.encode({field_name: value})
	_peer.put_packet(packet)

func _process(_delta: float):
	while _peer.get_available_packet_count() > 0:
		var buf: PackedByteArray = _peer.get_packet()
		var fields: Dictionary = _schema.decode(buf)
		print("@Server: ", fields)
