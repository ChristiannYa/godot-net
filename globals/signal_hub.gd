extends Node

signal add_scene_at_transform_sig(at: Transform3D, scene: PackedScene, on_ready: Callable)
signal player_states_live_sig(states: Dictionary)
signal player_sid_sig(sid: int)
signal player_spawn_loc_sig(loc: Vector3)

func emit_add_scene_at_transform(at: Transform3D, scene: PackedScene, on_ready: Callable = Callable()): add_scene_at_transform_sig.emit(at, scene, on_ready)
func emit_player_states_live(states: Dictionary): player_states_live_sig.emit(states)
func emit_player_sid(sid: int): player_sid_sig.emit(sid)
func emit_player_spawn_loc(loc: Vector3): player_spawn_loc_sig.emit(loc)
