extends Node

@onready var player: Player = get_parent()

func _ready() -> void:
	player.jump_sig.connect(_on_jump)
	player.crouch_start_sig.connect(_on_crouch_start)
	player.crouch_end_sig.connect(_on_crouch_end)

func _on_jump():
	NetClient.send_input("IsJumping", 1)

func _on_crouch_start():
	NetClient.send_input("IsCrouching", 1)

func _on_crouch_end():
	NetClient.send_input("IsCrouching", 0)

