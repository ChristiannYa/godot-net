extends Node

const RENDER_DELAY_MS := 100
const _SNAPSHOT_HZ := 60
const _BURST_ALLOWANCE := 10

var _peer := PacketPeerUDP.new()
var codec := UdpCodec.create()

var state := UdpState.create(
	int(RENDER_DELAY_MS * _SNAPSHOT_HZ / 1000.0) + _BURST_ALLOWANCE
)

## Fetched once: every call to `state.players()` crosses into Rust
var players := state.players()

var _legacy_state := UdpLegacyState.new()
var _rel := UdpReliable.new()

var _rcvr := UdpRecvr.new(_peer, _rel, _legacy_state)
var _oneshot_ctr: UdpOneShotCounter = UdpOneShotCounter.new()

var sender: UdpSender = UdpSender.new(_peer, _rel, _oneshot_ctr)


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


func is_synced(sid: int) -> bool:
	return _legacy_state.is_synced(sid)


func player_states() -> Dictionary:
	return _legacy_state.players()
