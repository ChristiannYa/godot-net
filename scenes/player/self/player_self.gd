class_name PlayerSelf
extends Player

func _ready():
	super._ready()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		_cam_handle_mouse_release()

func _cam_handle_mouse_release():
	Input.mouse_mode = (
		Input.MOUSE_MODE_VISIBLE
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
		else Input.MOUSE_MODE_CAPTURED
	)
