extends Node

signal player_states_sig(states: Dictionary)
signal player_sid_sig(sid: int)

func emit_player_states(states: Dictionary): player_states_sig.emit(states)
func emit_player_sid(sid: int): player_sid_sig.emit(sid)
