class_name Player
extends CharacterBody3D

const _GRAVITY := 30.0

const _M_ROTATE_LERP := 9.0
const _M_SPEED := 6.0
const _M_DECC := 20.0
const _M_JUMP_VEL := 14.0

const _MOUSE_SENS := 0.003

const _CAM_PITCH_MIN: float = deg_to_rad(-70.0)
const _CAM_PITCH_MAX: float = deg_to_rad(70.0)

@onready var body: MeshInstance3D = $Body
@onready var camera_controller: Node3D = $CameraController
@onready var spring_arm: SpringArm3D = $CameraController/SpringArm3D

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent):
	if event is InputEventMouseMotion: 
		handle_mouse_cam(event.relative.x, event.relative.y)

func _physics_process(delta: float):
	handle_gravity(delta)
	handle_movement(delta)
	move_and_slide()

func handle_gravity(delta: float):
	self.velocity.y += -_GRAVITY * delta

func handle_movement(delta: float):
	# Get direction that the user wants to move to
	var inp_dir: Vector2 = Input.get_vector("m_left", "m_right", "m_fwd", "m_back")
	var cam_glob_basis: Basis = camera_controller.global_transform.basis
	var dir: Vector3 = cam_glob_basis.x * inp_dir.x + cam_glob_basis.z * inp_dir.y

	if dir.length() > 0.01: 
		# Handle yaw rotation
		var local_dir: Vector3 = self.global_transform.basis.inverse() * dir
		body.rotation.y = lerp_angle(
			body.rotation.y,
			atan2(-local_dir.x, -local_dir.z),
			_M_ROTATE_LERP * delta
		)

		# Handle movement
		self.velocity.x = dir.x * _M_SPEED
		self.velocity.z = dir.z * _M_SPEED
	else:
		# Stop player from moving continuously
		self.velocity.x = move_toward(self.velocity.x, 0.0, _M_DECC * delta)
		self.velocity.z = move_toward(self.velocity.z, 0.0, _M_DECC * delta)

	# Handle jump
	if Input.is_action_just_pressed("m_jump") and self.is_on_floor():
		self.velocity.y = _M_JUMP_VEL

func handle_mouse_cam(x: float, y: float):	
	# Yaw
	camera_controller.rotate_y(-x * _MOUSE_SENS)

	# Pitch
	spring_arm.rotation.x = clamp(
		spring_arm.rotation.x - y * _MOUSE_SENS,
		_CAM_PITCH_MIN,
		_CAM_PITCH_MAX
	)
