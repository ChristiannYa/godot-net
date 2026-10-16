class_name PlayerRemote
extends Player


func _process(delta: float):
	super._process(delta)

	# Moment in the past being shown on the sceen (now - delay)
	var render_t: float = UTime.now_s() - UdpClient.RENDER_DELAY_MS / 1000.0

	var ss: PackedFloat32Array = UdpClient.poses.sample(sid, render_t)
	if ss.is_empty():
		return

	set_pose(
		Player.Pose.new(ss[0], ss[1], ss[2], ss[3], ss[4] == 1.0),
		Player.YawSource.SERVER
	)
