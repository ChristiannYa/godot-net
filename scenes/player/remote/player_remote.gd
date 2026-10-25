class_name PlayerRemote
extends Player


func _process(delta: float):
	super._process(delta)

	var ss: PackedFloat32Array = UdpClient.players.sample(
		sid, UdpClient.state.render_t(UTime.now_s())
	)
	if ss.is_empty():
		return

	set_pose(
		Player.Pose.new(ss[0], ss[1], ss[2], ss[3], ss[4] == 1.0),
		Player.YawSource.SERVER
	)
