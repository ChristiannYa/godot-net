extends Node

const _PLAYER_SELF: PackedScene = preload("res://scenes/player/self/player_self.tscn")
const _PLAYER_REMOTE: PackedScene = preload("res://scenes/player/remote/player_remote.tscn")

var _sid := -1
var _spawned := {}

func _ready():
	SignalHub.player_sid_sig.connect(_on_player_sid)
	SignalHub.player_states_live_sig.connect(_on_player_states_live)

func _on_player_sid(sid: int):
	_sid = sid

func _on_player_states_live(states: Dictionary):
	if _sid != -1 and !_spawned.has(_sid):
		_handle_spawn(_PLAYER_SELF, states, _sid)

	for sid in states:
		if sid == _sid or _spawned.has(sid): continue
		_handle_spawn(_PLAYER_REMOTE, states, sid)

func _handle_spawn(resr: PackedScene, states: Dictionary, sid: int):
	var state: Dictionary = states[sid]
	
	var location_set = state.has("LocationX") and state.has("LocationZ")
	var color_set = state.has("ColorH") and state.has("ColorS") and state.has("ColorV")

	if location_set and color_set:
		SignalHub.emit_add_scene_at_transform(
			Transform3D(Basis(), _get_spawn_pos(state, sid)),
			resr,
			func(player: Player):
				player.sid = sid
				player.player_color = _get_color(state)
		)
		_spawned[sid] = true

func _get_spawn_pos(state: Dictionary, sid: int) -> Vector3:
	var loc: Vector3 = NetClient.net_pkt_codec.decode_loc(state["LocationX"], state["LocationZ"])
	var y = 1.5 if NetClient.is_synced(sid) else 800.0
	return Vector3(loc.x, y, loc.z)

func _get_color(state: Dictionary) -> Color:
	return NetClient.net_pkt_codec.decode_hsv(
		state["ColorH"], state["ColorS"], state["ColorV"]
	)
