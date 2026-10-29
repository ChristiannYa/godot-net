extends Node

@onready var player: PlayerSelf = self.get_parent()

# The counter now lives and dies with the node, while prev_edges lives in
# UdpLocalSim on the global. If the node were ever recreated, the counter would
# restart at 0 while prev_edges holds the old value. Both client and server
# would see a change and fire one phantom jump.
# It's harmless today, because  the node is spawned once per session
# (_spawned in spwan.gd) and never dies
var _oneshot_ctr := UdpOneShotCounter.new()


func _process(_delta: float):
	# pass
	# This call is harmless for the moment because the player is moved only by
	# the server. Whenever client-side prediction is added, applying the server
	# pose every frame would overwrite the predicted position.
	player.utils.net.movement.apply_server_pose()


func _physics_process(_delta: float):
	_handle_intent_send()


func _input(event: InputEvent):
	if event.is_action_pressed("m_jump"):
		_oneshot_ctr.reg("jump")


func _handle_intent_send():
	var jump_ct: Variant = _oneshot_ctr.ct("jump")
	if jump_ct == null:
		return

	var mv: Vector2 = Input.get_vector("m_left", "m_right", "m_fwd", "m_back")
	var cam_yaw: float = player.cam_yaw()
	var is_crouching: bool = Input.is_action_pressed("m_crouch")
	UdpClient.sender.intent(mv, cam_yaw, is_crouching, jump_ct)

	var seq: int = UdpClient.sender.intent_seq()
	UdpClient.local_sim.tick(seq, mv.x, mv.y, cam_yaw, is_crouching, jump_ct)
