extends Node

@onready var player: PlayerSelf = self.get_parent()


func _ready():
	SignalHub.player_states_live_sig.connect(_on_player_states_live_sig)


func _physics_process(_delta: float):
	UdpClient.send_intent(
		Input.get_vector("m_left", "m_right", "m_fwd", "m_back"),
		player.cam_yaw(),
		Input.is_action_pressed("m_crouch")
	)


func _input(event: InputEvent):
	if event.is_action_pressed("m_jump"):
		UdpClient.reg_oneshot("jump")


func _on_player_states_live_sig(states: Dictionary):
	player.utils.net.movement.apply_server_pos(states)
	_apply_crouch(states)


func _apply_crouch(states: Dictionary):
	var is_crouching: Variant = player.utils.net.movement.get_server_crouch(
		states
	)
	if is_crouching != null:
		player.set_is_crouching(is_crouching)
