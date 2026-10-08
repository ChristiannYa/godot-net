class_name PlayerUtilsNetMovement
extends PlayerUtilsProvider

## This player's position from a states dictionary, or null if the
## dictionary has no position for them yet
func get_server_pos(states: Dictionary) -> XZ:
	var state: Dictionary = states.get(p.sid, {})
	if !state.has("LocationX") or !state.has("LocationZ"): return null

	var pos: Vector3 = UdpSkt.udp_codec.decode_loc(
		state["LocationX"],
		state["LocationZ"]
	)
	return XZ.new(pos.x, pos.z)

func apply_server_pos(states: Dictionary):
	var pos: XZ = get_server_pos(states)
	if pos == null: return

	p.global_position.x = pos.x
	p.global_position.z = pos.z
