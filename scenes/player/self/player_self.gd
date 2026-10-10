class_name PlayerSelf
extends Player

const _MOUSE_SENS := 0.003
const _CAM_PITCH_MIN: float = deg_to_rad(-70)
const _CAM_PITCH_MAX: float = deg_to_rad(70)

@onready var camera_controller: Node3D = $CameraController
@onready var spring_arm: SpringArm3D = $CameraController/SpringArm3D

# func _ready():
# 	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event: InputEvent):
	if (
		event is InputEventMouseMotion
		and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	):
		_cam_handle_mouse_control(event.relative.x, event.relative.y)

	if event.is_action_pressed("ui_cancel"):
		_cam_handle_mouse_release()


## Camera wrapped to [-PI, PI) for the intent. The server's yaw quantiezer
## clamps instead of wrapping, so an unwrapped angle would stick at the edge
func cam_yaw() -> float:
	return wrapf(camera_controller.rotation.y, -PI, PI)


func _cam_handle_mouse_control(x: float, y: float):
	camera_controller.rotate_y(-x * _MOUSE_SENS)
	body.rotation.y = camera_controller.rotation.y
	spring_arm.rotation.x = clamp(
		spring_arm.rotation.x - y * _MOUSE_SENS,
		_CAM_PITCH_MIN,
		_CAM_PITCH_MAX
	)


func _cam_handle_mouse_release():
	Input.mouse_mode = (
		Input.MOUSE_MODE_VISIBLE
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
		else Input.MOUSE_MODE_CAPTURED
	)
