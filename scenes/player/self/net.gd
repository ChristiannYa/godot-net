extends Node

@onready var player: PlayerSelf = self.get_parent()


func _ready():
	SignalHub.player_states_live_sig.connect(
		player.utils.net.movement.apply_server_pos
	)


func _physics_process(_delta: float):
	UdpClient.send_intent(
		Input.get_vector("m_left", "m_right", "m_fwd", "m_back"),
		player.cam_yaw()
	)


func _input(event: InputEvent):
	if event.is_action_pressed("m_jump"):
		UdpClient.reg_oneshot("jump")
