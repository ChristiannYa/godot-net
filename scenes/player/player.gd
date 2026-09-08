class_name Player
extends CharacterBody3D

const _GRAVITY := 30.0

const _M_ROTATE_LERP := 9.0
const _M_SPEED := 6.0
const _M_DECC := 20.0
const _M_JUMP_VEL := 14.0
const _M_CROUCH_HEIGHT := 1.0
const _M_CROUCH_SPEED := 6.0

const _MOUSE_SENS := 0.003

const _CAM_PITCH_MIN: float = deg_to_rad(-70.0)
const _CAM_PITCH_MAX: float = deg_to_rad(70.0)

signal jump_sig
signal crouch_start_sig
signal crouch_end_sig

@onready var body: MeshInstance3D = $Body
@onready var body_collision: CollisionShape3D = $BodyCollision
@onready var camera_controller: Node3D = $CameraController
@onready var spring_arm: SpringArm3D = $CameraController/SpringArm3D

var _def_rad: float
var _def_height: float
var _cur_height: float

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# Duplicate shared resources so transforming this instance doesn't affect other
	# Player instances using the same scene
	var body_collision_shape: Shape3D = body_collision.shape.duplicate()
	body_collision.shape = body_collision_shape
	var body_mesh: Mesh = self.body.mesh.duplicate()
	self.body.mesh = body_mesh

	_def_rad = body_collision_shape.radius
	_def_height = body_collision_shape.height
	_cur_height = _def_height

func _input(event: InputEvent):
	if event is InputEventMouseMotion: 
		_cam_handle_mouse_control(event.relative.x, event.relative.y)

	if event.is_action_pressed("ui_cancel"):
		_cam_handle_mouse_release()

func _physics_process(delta: float):
	_handle_gravity(delta)
	_m_handle_movement(delta)
	self.move_and_slide()

func _handle_gravity(delta: float):
	self.velocity.y += -_GRAVITY * delta

func _m_handle_movement(delta: float):
	var move_dir: Vector3 = _m_get_move_direction()
	_m_handle_yaw_rotation(delta, move_dir)
	_m_handle_move_direction(delta, move_dir)
	_m_handle_jump()
	_m_handle_crouch(delta)

func _m_get_move_direction() -> Vector3:
	var inp_dir: Vector2 = Input.get_vector("m_left", "m_right", "m_fwd", "m_back")
	var cam_glob_basis: Basis = camera_controller.global_transform.basis
	return cam_glob_basis.x * inp_dir.x + cam_glob_basis.z * inp_dir.y

func _m_handle_yaw_rotation(delta: float, move_dir: Vector3):
	if move_dir.length() <= 0.0: return
	var local_dir: Vector3 = self.global_transform.basis.inverse() * move_dir
	body.rotation.y = lerp_angle(
		body.rotation.y,
		atan2(-local_dir.x, -local_dir.z),
		_M_ROTATE_LERP * delta
	)

func _m_handle_move_direction(delta: float, move_dir: Vector3):
	var is_moving: bool = move_dir.length() > 0.01
	self.velocity.x = move_dir.x * _M_SPEED if is_moving else move_toward(self.velocity.x, 0.0, _M_DECC * delta)
	self.velocity.z = move_dir.z * _M_SPEED if is_moving else move_toward(self.velocity.z, 0.0, _M_DECC * delta)

func _m_handle_jump():
	if !(Input.is_action_just_pressed("m_jump") and self.is_on_floor()): return
	self.velocity.y = _M_JUMP_VEL
	jump_sig.emit()

func _m_handle_crouch(delta: float):
	if !self.is_on_floor(): return
	var prev_height: float = _cur_height

	if Input.is_action_pressed("m_crouch"): 
		_cur_height -= _M_CROUCH_SPEED * delta
	else: 
		_cur_height += _M_CROUCH_SPEED * delta

	_cur_height = clamp(_cur_height, _M_CROUCH_HEIGHT, _def_height)

	if Input.is_action_just_pressed("m_crouch"):
		crouch_start_sig.emit()
	elif Input.is_action_just_released("m_crouch"):
		crouch_end_sig.emit()

	if _cur_height != prev_height:
		body_collision.shape.height = _cur_height
		self.body.mesh.height = _cur_height

		# Push the shape and mesh down so the bottom stays fixed and only the top
		# appears to compress
		var ofs: float = -(_def_height - _cur_height) * 0.5
		body_collision.position.y = ofs
		self.body.position.y = ofs	

func _cam_handle_mouse_control(x: float, y: float):	
	# Yaw
	camera_controller.rotate_y(-x * _MOUSE_SENS)

	# Pitch
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
