class_name PlayerSelf
extends Player

func _ready():
	super._ready()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float):
	super._physics_process(delta)
	UdpSkt.send_intent(Input.get_vector("m_left", "m_right", "m_fwd", "m_back"))

func _input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		_cam_handle_mouse_release()

func _get_move_direction() -> Vector3:
	return Vector3.ZERO

func _cam_handle_mouse_release():
	Input.mouse_mode = (
		Input.MOUSE_MODE_VISIBLE
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
		else Input.MOUSE_MODE_CAPTURED
	)
