extends Node

var _peer := PacketPeerUDP.new()
var codec := UdpCodec.create()

var _oneshot_ctr: UdpOneShotCounter = UdpOneShotCounter.new()
var _rel := UdpReliable.new()
var sender: UdpSender = UdpSender.new(_peer, _rel, _oneshot_ctr)
var _rcvr := UdpRecvr.new(_peer, _rel)

var state := UdpState.create()
var players := state.players()  # every call to `state.players()` crosses rust


func _ready():
	_peer.bind(0)
	_peer.set_dest_address("10.0.0.4", 34254)
	sender.single("DevPing", 1)


func _process(_delta: float):
	while _peer.get_available_packet_count() > 0:
		var pkt = _peer.get_packet()
		_rcvr.recv(pkt)

	sender.due_rel()


func reg_oneshot(field: String):
	_oneshot_ctr.reg(field)
