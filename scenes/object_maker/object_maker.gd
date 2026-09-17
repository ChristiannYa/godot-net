extends Node3D

func _ready():
	SignalHub.add_scene_at_transform_sig.connect(_on_add_scene_at_transform)

func _on_add_scene_at_transform(at: Transform3D, scene: PackedScene, on_ready: Callable):
	var node: Node3D = scene.instantiate()
	node.transform = at
	if on_ready.is_valid(): on_ready.call(node)
	add_child.call_deferred(node)
