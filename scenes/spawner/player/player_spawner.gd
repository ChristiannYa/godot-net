extends Node

const _PLAYER_SELF := preload("res://scenes/player/self/player_self.tscn")
const _PLAYER_REMOTE := preload("res://scenes/player/remote/player_remote.tscn")

var _cur_player_sid := -1

## sid -> Player
var _spawned := {} 

func _ready() -> void:
	SignalHub.player_sid_sig.connect(_on_player_sid)
	SignalHub.player_states_live_sig.connect(_on_player_states_live)

func _on_player_sid(sid: int):
	_cur_player_sid = sid

func _on_player_states_live(states: Dictionary):
	if _cur_player_sid != -1 and !_spawned.has(_cur_player_sid):
		var state = states.get(_cur_player_sid, {})
		if state.has("LocationX") and state.has("LocationZ"):
			_spawned[_cur_player_sid] = _spawn_self(_cur_player_sid)

	for sid in states:
		if sid == _cur_player_sid or _spawned.has(sid): continue
		var state: Dictionary = states[sid]
		if state.has("LocationX") and state.has("LocationZ"):
			_spawned[sid] = _spawn_remote(sid)

func _spawn_self(sid: int) -> Player:
	var player: Player = _PLAYER_SELF.instantiate()
	add_child(player)
	player.global_position = _spawn_pos(sid)
	player.sid = sid
	return player

func _spawn_remote(sid: int) -> Player:
	var player: Player = _PLAYER_REMOTE.instantiate()
	add_child(player)
	player.global_position = _spawn_pos(sid)
	player.sid = sid
	return player

func _spawn_pos(sid: int) -> Vector3:
	var state = NetClient.get_player_state(sid)
	var x = NetClient.schema.decode_loc_x(state["LocationX"])
	var z = NetClient.schema.decode_loc_z(state["LocationZ"])
	var y = 1.5 if NetClient.is_synced(sid) else 800.0
	return Vector3(x, y, z)
