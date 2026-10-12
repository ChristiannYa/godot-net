class_name PlayerUtilsNetMovement
extends PlayerUtilsProvider


## Returns `float` or `null`
func get_server_y(states: Dictionary) -> Variant:
	var state: Dictionary = states.get(p.sid, {})
	if !state.has("LocationY"):
		return null

	return UdpSkt.udp_codec.decode_y(state["LocationY"])


func get_server_yaw(states: Dictionary) -> float:
	var state: Dictionary = states.get(p.sid, {})
	if !state.has("Yaw"):
		return 0.0

	return UdpSkt.udp_codec.decode_yaw(state["Yaw"])


## This player's position from a states dictionary, or null if the
## dictionary has no position for them yet
func get_server_pos(states: Dictionary) -> XZ:
	var state: Dictionary = states.get(p.sid, {})
	if !state.has("LocationX") or !state.has("LocationZ"):
		return null

	var pos: Vector3 = UdpSkt.udp_codec.decode_loc(
		state["LocationX"], state["LocationZ"]
	)
	return XZ.new(pos.x, pos.z)


func apply_server_pos(states: Dictionary):
	var pos: XZ = get_server_pos(states)
	if pos == null:
		return

	p.global_position.x = pos.x
	p.global_position.z = pos.z

	var y: Variant = get_server_y(states)
	if y != null:
		p.global_position.y = y
