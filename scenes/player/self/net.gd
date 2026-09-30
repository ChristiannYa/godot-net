extends Node

@onready var player: PlayerSelf = self.get_parent()

func _ready():
	player.jump_sig.connect(_on_jump)
	player.land_sig.connect(_on_land)
	player.crouch_start_sig.connect(_on_crouch_start)
	player.crouch_end_sig.connect(_on_crouch_end)

func _on_jump():
	UdpSkt.send_input_rel("IsJumping", 1)

func _on_land():
	UdpSkt.send_input_rel("IsJumping", 0)

func _on_crouch_start():
	UdpSkt.send_input_rel("IsCrouching", 1)

func _on_crouch_end():
	UdpSkt.send_input_rel("IsCrouching", 0)
