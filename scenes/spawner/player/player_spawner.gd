extends Node

const _PLAYER_SELF: Resource = preload("res://scenes/player/self/player_self.tscn")
const _PLAYER_REMOTE: Resource = preload("res://scenes/player/remote/player_remote.tscn")

var _sid := -1

## sid -> Player
var _spawned := {} 

func _ready() -> void:
	SignalHub.player_sid_sig.connect(_on_player_sid)
	SignalHub.player_states_live_sig.connect(_on_player_states_live)

func _on_player_sid(sid: int):
	_sid = sid

func _on_player_states_live(states: Dictionary):
	if _sid != -1 and !_spawned.has(_sid):
		_handle_reg(_PLAYER_SELF, states, _sid)

	for sid in states:
		if sid == _sid or _spawned.has(sid): continue
		_handle_reg(_PLAYER_REMOTE, states, sid)

func _handle_reg(resr: Resource, states: Dictionary, sid: int):
	var state: Dictionary = states[sid]
	if state.has("LocationX") and state.has("LocationZ"):
		_spawned[sid] = _get_spawned(resr, state, sid)

func _get_spawned(resr: Resource, state: Dictionary, sid: int):
	var player: Player = resr.instantiate()
	add_child(player)
	player.global_position = _get_pos(state, sid)
	player.sid = sid
	return player

func _get_pos(state: Dictionary, sid: int) -> Vector3:
	var x = NetClient.net_pkt_codec.decode_loc_x(state["LocationX"])
	var z = NetClient.net_pkt_codec.decode_loc_z(state["LocationZ"])
	var y = 1.5 if NetClient.is_synced(sid) else 800.0
	return Vector3(x, y, z)
