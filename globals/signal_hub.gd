extends Node

signal player_states_live_sig(states: Dictionary)
signal player_sid_sig(sid: int)
signal player_spawn_loc_sig(loc: Vector3)

func emit_player_states_live(states: Dictionary): player_states_live_sig.emit(states)
func emit_player_sid(sid: int): player_sid_sig.emit(sid)
func emit_player_spawn_loc(loc: Vector3): player_spawn_loc_sig.emit(loc)
