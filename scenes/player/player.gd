class_name Player
extends CharacterBody3D

enum YawSource { SERVER, LOCAL }

const _HEIGHT = 2.0
const _CROUCH_HEIGHT := 1.0
const _CROUCH_SPEED := 6.0

signal color_changed_sig

@export var color: Color = Color.WHITE:
	set(val):
		color = val
		color_changed_sig.emit()

@onready var body: MeshInstance3D = $Body
@onready var collision: CollisionShape3D = $Collision
@onready var sid_label: Label3D = $SidLabel

var utils: PlayerUtils

var sid: int = -1

var _is_crouching := false
var _height: float = _HEIGHT


func _init():
	utils = PlayerUtils.new(self)


func _physics_process(_delta: float):
	self.move_and_slide()


func _process(delta: float):
	var target: float = _CROUCH_HEIGHT if _is_crouching else _HEIGHT
	_height = move_toward(_height, target, _CROUCH_SPEED * delta)
	_apply_height()


## `LOCAl` is for `PlayerSelf` because the camera already turns the body
## instantly. Applying the server's yaw would snap it back to an old value
## each snapshot.
func set_pose(pose: Pose, yaw_src: YawSource):
	global_position.x = pose.x
	global_position.y = pose.y
	global_position.z = pose.z

	if yaw_src == YawSource.SERVER:
		set_yaw(pose.yaw)

	set_is_crouching(pose.is_crouching)


## Turns the visible body, not the root, so that children of the root (like
## the camera on PlayerSelf) don't inherit the roatation
func set_yaw(yaw: float):
	body.rotation.y = yaw


func set_is_crouching(val: bool):
	_is_crouching = val


func _apply_height():
	(body.mesh as CapsuleMesh).height = _height
	body.position.y = _height / 2.0

	(collision.shape as CapsuleShape3D).height = _height
	collision.position.y = _height / 2.0

	sid_label.position.y = _height + 0.4
