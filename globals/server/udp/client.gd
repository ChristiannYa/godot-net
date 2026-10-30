extends Node

var _peer := PacketPeerUDP.new()
var codec := UdpCodec.create()

var _rel := UdpReliable.new()
var sender: UdpSender = UdpSender.new(_peer, _rel)
var _rcvr := UdpRecvr.new(_peer, _rel)

var state := UdpState.create()

# every call crosses rust, so we call it once here
var players := state.players()
var locsim := state.locsim()


func _ready():
	_peer.bind(0)
	_peer.set_dest_address("10.0.0.4", 34254)
	sender.single("DevPing", 1)


func _process(_delta: float):
	while _peer.get_available_packet_count() > 0:
		var pkt = _peer.get_packet()
		_rcvr.recv(pkt)

	sender.due_rel()
