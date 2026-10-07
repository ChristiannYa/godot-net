class_name PlayerUtilsNetMovement
extends PlayerUtilsProvider

func apply_server_loc(states: Dictionary):
	var state: Dictionary = states.get(p.sid, {})
	if !state.has("LocationX") or !state.has("LocationZ"): return

	var loc: Vector3 = UdpSkt.udp_codec.decode_loc(
		state["LocationX"],
		state["LocationZ"]
	)
	p.global_position.x = loc.x
	p.global_position.z = loc.z
