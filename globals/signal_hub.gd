extends Node

signal player_states_live_sig(states: Dictionary)
signal player_sid_sig(sid: int)

func emit_player_states_live(states: Dictionary): player_states_live_sig.emit(states)
func emit_player_sid(sid: int): player_sid_sig.emit(sid)
