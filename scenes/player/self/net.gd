extends Node

@onready var player: PlayerSelf = self.get_parent()


func _process(_delta: float):
	# This call is harmless for the moment because the player is moved only by
	# the server. Whenever client-side prediction is added, applying the server
	# pose every frame would overwrite the predicted position.
	player.utils.net.movement.apply_server_pose()


func _physics_process(_delta: float):
	UdpClient.sender.intent(
		Input.get_vector("m_left", "m_right", "m_fwd", "m_back"),
		player.cam_yaw(),
		Input.is_action_pressed("m_crouch")
	)


func _input(event: InputEvent):
	if event.is_action_pressed("m_jump"):
		UdpClient.reg_oneshot("jump")
