class_name PlayerUtilsNetMovement
extends PlayerUtilsProvider


func apply_server_pose():
	var ss: PackedFloat32Array = UdpClient.poses.latest(p.sid)
	if ss.is_empty():
		return

	p.set_pose(
		Player.Pose.new(ss[0], ss[1], ss[2], ss[3], ss[4] == 1.0),
		Player.YawSource.LOCAL
	)
