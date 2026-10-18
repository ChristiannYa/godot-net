class_name PlayerSpawn
extends Node

const _PLAYER_SELF: PackedScene = preload(
	"res://scenes/player/self/player_self.tscn"
)
const _PLAYER_REMOTE: PackedScene = preload(
	"res://scenes/player/remote/player_remote.tscn"
)

var _sid := -1
var _spawned := {}


func _ready():
	SignalHub.player_sid_sig.connect(_on_player_sid)
	SignalHub.player_states_live_sig.connect(_on_player_states_live)


func _on_player_sid(sid: int):
	_sid = sid


func _on_player_states_live(_states: Dictionary):
	if _sid != -1 and !_spawned.has(_sid):
		_handle_spawn(_PLAYER_SELF, _sid)

	## @TODO
	## This adds a small FFI call per snapshot.
	## Create a "new sids since last call" function so it runs when someone
	## actually appears
	for sid in UdpClient.players.sids():
		if sid == _sid or _spawned.has(sid):
			continue
		_handle_spawn(_PLAYER_REMOTE, sid)


func _handle_spawn(resr: PackedScene, sid: int):
	var pose := UdpClient.players.latest(sid)
	var hsv := UdpClient.players.color(sid)
	if pose.is_empty() or hsv.is_empty():
		return  # Not everything is known yet

	var color := Color.from_hsv(hsv[0], hsv[1], hsv[2])
	SignalHub.emit_add_scene_at_transform(
		Transform3D(Basis(), _get_spawn_pos(pose)),
		resr,
		func(player: Player):
			player.sid = sid
			player.color = color
	)
	_spawned[sid] = true


func _get_spawn_pos(pose: PackedFloat32Array) -> Vector3:
	return Vector3(pose[0], pose[1], pose[2])
