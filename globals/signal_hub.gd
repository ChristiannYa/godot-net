extends Node

signal add_scene_at_transform_sig(
	at: Transform3D, scene: PackedScene, on_ready: Callable
)


func emit_add_scene_at_transform(
	at: Transform3D, scene: PackedScene, on_ready: Callable = Callable()
):
	add_scene_at_transform_sig.emit(at, scene, on_ready)


signal players_updated_sig


func emit_players_updated():
	players_updated_sig.emit()
