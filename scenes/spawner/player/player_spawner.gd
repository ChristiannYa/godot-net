extends Node

var cur_player_sid := -1
var _spawned := {}

func _ready() -> void:
	SignalHub.player_sid_sig.connect(_on_player_sid)
	SignalHub.player_states_live_sig.connect(_on_player_states_live)

func _on_player_sid(sid: int):
	cur_player_sid = sid

func _on_player_states_live(states: Dictionary):
	for sid in states:
		if sid == cur_player_sid: continue
		_spawned[sid] = {}
