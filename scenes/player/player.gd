class_name Player
extends CharacterBody3D

const _GRAVITY := 30.0

@export var player_color: Color = Color.WHITE:
	set(val):
		player_color = val
		_c_apply_player_color()

@onready var body: MeshInstance3D = $Body
@onready var sid_label: Label3D = $SidLabel

var utils: PlayerUtils

var sid: int = -1

func _init():
	utils = PlayerUtils.new(self)

func _ready():
	_c_apply_player_color()
	_apply_sid_label()

func _physics_process(delta: float):
	_handle_gravity(delta)
	self.move_and_slide()

func _handle_gravity(delta: float):
	self.velocity.y += -_GRAVITY * delta

# Overridden by anything that actually drives movement (local input or remote
# player).
func _get_move_direction() -> Vector3:
	return Vector3.ZERO

func _c_apply_player_color():
	if !self.is_inside_tree() or body == null: return

	var mat: StandardMaterial3D = body.material_override
	if mat == null:
		mat = StandardMaterial3D.new()
		body.material_override = mat

	mat.albedo_color = player_color

func _apply_sid_label():
	sid_label.text = "sid=%d" % sid
