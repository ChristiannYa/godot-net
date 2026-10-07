class_name PlayerRemote
extends Player

func _ready():
	super._ready()
	SignalHub.player_states_live_sig.connect(_on_player_states_live)

func _on_player_states_live(states: Dictionary):
	var state: Dictionary = states.get(sid, {})
	if !state.has("LocationX") or !state.has("LocationZ"): return

	var loc: Vector3 = UdpSkt.udp_codec.decode_loc(
		state["LocationX"],
		state["LocationZ"]
	)
	global_position.x = loc.x
	global_position.z = loc.z
