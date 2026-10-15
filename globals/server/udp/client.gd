extends Node

var _udp_peer := PacketPeerUDP.new()
var udp_codec := UdpCodec.create()

var _state := NetState.new()
var _rel := NetReliable.new()

var _pkt_rcvr := PktRecvr.new(_udp_peer, _rel, _state)
var _oneshot_cts: OneShot = OneShot.new()

var sender: UdpSender = UdpSender.new(_udp_peer, _rel, _oneshot_cts)


func _ready():
	_udp_peer.bind(0)
	_udp_peer.set_dest_address("10.0.0.4", 34254)
	sender.def("DevPing", 1)


func _process(_delta: float):
	while _udp_peer.get_available_packet_count() > 0:
		var pkt = _udp_peer.get_packet()
		_pkt_rcvr.recv(pkt)

	sender.due_rel()


func reg_oneshot(field: String):
	_oneshot_cts.reg(field)


func is_synced(sid: int) -> bool:
	return _state.is_synced(sid)


func player_states() -> Dictionary:
	return _state.players()
