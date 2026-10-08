extends Node

signal add_scene_at_transform_sig(at: Transform3D, scene: PackedScene, on_ready: Callable)
func emit_add_scene_at_transform(at: Transform3D, scene: PackedScene, on_ready: Callable = Callable()): add_scene_at_transform_sig.emit(at, scene, on_ready)

signal player_states_live_sig(states: Dictionary)
func emit_player_states_live(states: Dictionary): player_states_live_sig.emit(states)

signal player_snapshot_sig(states: Dictionary)
func  emit_player_snapshot_sig(states: Dictionary): player_snapshot_sig.emit(states)

signal player_sid_sig(sid: int)
func emit_player_sid(sid: int): player_sid_sig.emit(sid)

