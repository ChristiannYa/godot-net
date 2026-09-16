class_name Player
extends CharacterBody3D

const _GRAVITY := 30.0

const _M_ROTATE_LERP := 9.0
const _M_SPEED := 6.0
const _M_DECC := 20.0
const _M_JUMP_VEL := 14.0
const _M_CROUCH_HEIGHT := 1.0
const _M_CROUCH_SPEED := 6.0

signal jump_sig
signal land_sig
signal crouch_start_sig
signal crouch_end_sig

@export var player_color: Color = Color.WHITE:
	set(val):
		player_color = val
		_c_apply_player_color()

@onready var body: MeshInstance3D = $Body
@onready var body_collision: CollisionShape3D = $Collision

var _def_rad: float
var _def_height: float
var _cur_height: float

var _was_airborne := false
var _was_crouching := false

func _ready():
	var body_collision_shape: Shape3D = body_collision.shape.duplicate()
	body_collision.shape = body_collision_shape
	var body_mesh: Mesh = self.body.mesh.duplicate()
	self.body.mesh = body_mesh

	_def_rad = body_collision_shape.radius
	_def_height = body_collision_shape.height
	_cur_height = _def_height

	_c_apply_player_color()

func _physics_process(delta: float):
	_handle_gravity(delta)
	_m_handle_movement(delta)
	self.move_and_slide()

func _handle_gravity(delta: float):
	self.velocity.y += -_GRAVITY * delta

func _m_handle_movement(delta: float):
	var move_dir: Vector3 = _get_move_direction()
	_m_handle_yaw_rotation(delta, move_dir)
	_m_handle_move_direction(delta, move_dir)
	_m_handle_jump()
	_m_handle_land()
	_m_handle_crouch(delta)

# Overridden by anything that actually drives movement (local input, network
# replication).
# Base default: a dummy that just stands there under gravity.
func _get_move_direction() -> Vector3:
	return Vector3.ZERO

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
	if !(_wants_to_jump() and self.is_on_floor()): return
	self.velocity.y = _M_JUMP_VEL
	jump_sig.emit()

func _wants_to_jump() -> bool:
	return false

func _m_handle_land():
	var is_airborne := !self.is_on_floor()
	if _was_airborne and !is_airborne:
		land_sig.emit()
	_was_airborne = is_airborne

func _m_handle_crouch(delta: float):
	if !self.is_on_floor(): return
	var prev_height: float = _cur_height

	var wants_to_crouch: bool = _wants_to_crouch()
	if wants_to_crouch: 
		_cur_height -= _M_CROUCH_SPEED * delta
	else: 
		_cur_height += _M_CROUCH_SPEED * delta

	_cur_height = clamp(_cur_height, _M_CROUCH_HEIGHT, _def_height)

	if wants_to_crouch and !_was_crouching:
		crouch_start_sig.emit()
	elif !wants_to_crouch and _was_crouching:
		crouch_end_sig.emit()

	_was_crouching = wants_to_crouch

	if _cur_height != prev_height:
		body_collision.shape.height = _cur_height
		self.body.mesh.height = _cur_height
		var ofs: float = -(_def_height - _cur_height) * 0.5
		body_collision.position.y = ofs
		self.body.position.y = ofs

func _wants_to_crouch() -> bool:
	return false

func _c_apply_player_color():
	if !self.is_inside_tree() or body == null: return

	var mat: StandardMaterial3D = body.material_override
	if mat == null:
		mat = StandardMaterial3D.new()
		body.material_override = mat

	mat.albedo_color = player_color
