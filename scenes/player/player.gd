class_name Player
extends CharacterBody3D

const _GRAVITY := 30.0

const _M_SPEED := 6.0
const _M_DECC := 20.0

@export var player_color: Color = Color.WHITE:
	set(val):
		player_color = val
		_c_apply_player_color()

@onready var body: MeshInstance3D = $Body
@onready var sid_label: Label3D = $SidLabel

var sid: int = -1

func _ready():
	_c_apply_player_color()
	_apply_sid_label()

func _physics_process(delta: float):
	_handle_gravity(delta)
	_m_handle_movement(delta)
	self.move_and_slide()

func _handle_gravity(delta: float):
	self.velocity.y += -_GRAVITY * delta

func _m_handle_movement(delta: float):
	var move_dir: Vector3 = _get_move_direction()
	_m_handle_move_direction(delta, move_dir)

# Overridden by anything that actually drives movement (local input or remote
# player).
func _get_move_direction() -> Vector3:
	return Vector3.ZERO

func _m_handle_move_direction(delta: float, move_dir: Vector3):
	var is_moving: bool = move_dir.length() > 0.01
	self.velocity.x = move_dir.x * _M_SPEED if is_moving else move_toward(self.velocity.x, 0.0, _M_DECC * delta)
	self.velocity.z = move_dir.z * _M_SPEED if is_moving else move_toward(self.velocity.z, 0.0, _M_DECC * delta)

func _c_apply_player_color():
	if !self.is_inside_tree() or body == null: return

	var mat: StandardMaterial3D = body.material_override
	if mat == null:
		mat = StandardMaterial3D.new()
		body.material_override = mat

	mat.albedo_color = player_color

func _apply_sid_label():
	sid_label.text = "sid=%d" % sid
