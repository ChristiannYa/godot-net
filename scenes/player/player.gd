class_name Player
extends CharacterBody3D

const _GRAVITY := 30.0

signal color_changed_sig

@export var color: Color = Color.WHITE:
	set(val):
		color = val
		color_changed_sig.emit()

@onready var body: MeshInstance3D = $Body
@onready var sid_label: Label3D = $SidLabel

var utils: PlayerUtils

var sid: int = -1


func _init():
	utils = PlayerUtils.new(self)


func _physics_process(delta: float):
	_handle_gravity(delta)
	self.move_and_slide()


func _handle_gravity(delta: float):
	self.velocity.y += -_GRAVITY * delta


## Turns the visible body, not the root, so that children of the root (like
## the camera on PlayerSelf) don't inherit the roatation
func face(yaw: float):
	body.rotation.y = yaw
