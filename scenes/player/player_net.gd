extends Node

@onready var player: Player = get_parent()

func _ready() -> void:
	player.jump_sig.connect(_on_jump)
	player.land_sig.connect(_on_land)
	player.crouch_start_sig.connect(_on_crouch_start)
	player.crouch_end_sig.connect(_on_crouch_end)
	SignalHub.player_sid_sig.connect(_on_player_sid)

func _on_jump():
	NetClient.send_input("IsJumping", 1)

func _on_land():
	NetClient.send_input("IsJumping", 0)

func _on_crouch_start():
	NetClient.send_input("IsCrouching", 1)

func _on_crouch_end():
	NetClient.send_input("IsCrouching", 0)

func _on_player_sid(sid: int):
	player.debug_label.text = "sid=%d" % sid
