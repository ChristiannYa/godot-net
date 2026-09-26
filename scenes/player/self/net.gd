extends Node

@onready var player: PlayerSelf = self.get_parent()

var _jump_ct := 0

var _file := "player/self/net"

func _ready():
	player.jump_sig.connect(_on_jump)
	player.land_sig.connect(_on_land)
	player.crouch_start_sig.connect(_on_crouch_start)
	player.crouch_end_sig.connect(_on_crouch_end)

func _on_jump():
	print("[%s, _on_jump_sig] ()" % _file)
	_jump_ct += 1
	print("[%s, _on_jump_sig] _jump_ct=%d" % [_file, _jump_ct])
	NetClient.send_input_rel("IsJumping", 1)

func _on_land():
	print("[%s, _on_land_sig] ()" % _file)
	NetClient.send_input_rel("IsJumping", 0)

func _on_crouch_start():
	NetClient.send_input_rel("IsCrouching", 1)

func _on_crouch_end():
	NetClient.send_input_rel("IsCrouching", 0)
