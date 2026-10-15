class_name PlayerUtilsNetMovement
extends PlayerUtilsProvider


func get_server_pose_or_null(states: Dictionary) -> Player.Pose:
	var state: Dictionary = states.get(p.sid, {})

	for key in ["LocationX", "LocationY", "LocationZ", "Yaw", "IsCrouching"]:
		if !state.has(key):
			return null

	var loc: Vector3 = UdpClient.udp_codec.decode_loc(
		state["LocationX"], state["LocationZ"]
	)
	var y: float = UdpClient.udp_codec.decode_y(state["LocationY"])
	var yaw: float = UdpClient.udp_codec.decode_yaw(state["Yaw"])
	var is_crouching: bool = state["IsCrouching"] == 1

	return Player.Pose.new(loc.x, y, loc.z, yaw, is_crouching)


func apply_server_pose(states: Dictionary):
	var pose: Player.Pose = get_server_pose_or_null(states)
	if pose == null:
		return
	p.set_pose(pose, Player.YawSource.LOCAL)
