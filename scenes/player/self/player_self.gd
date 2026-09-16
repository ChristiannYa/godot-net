class_name PlayerSelf
extends Player

const _MOUSE_SENS := 0.003
const _CAM_PITCH_MIN: float = deg_to_rad(-70.0)
const _CAM_PITCH_MAX: float = deg_to_rad(70.0)

@onready var camera_controller: Node3D = $CameraController
@onready var spring_arm: SpringArm3D = $CameraController/SpringArm3D
@onready var debug_label: Label3D = $DebugLabel

func _ready():
	super._ready()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent):
	if event is InputEventMouseMotion:
		_cam_handle_mouse_control(event.relative.x, event.relative.y)

	if event.is_action_pressed("ui_cancel"):
		_cam_handle_mouse_release()

func _get_move_direction() -> Vector3:
	var inp_dir: Vector2 = Input.get_vector("m_left", "m_right", "m_fwd", "m_back")
	var cam_glob_basis: Basis = camera_controller.global_transform.basis
	return cam_glob_basis.x * inp_dir.x + cam_glob_basis.z * inp_dir.y

func _cam_handle_mouse_control(x: float, y: float):
	camera_controller.rotate_y(-x * _MOUSE_SENS)
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
