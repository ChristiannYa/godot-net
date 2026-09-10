extends Node

signal player_states(states: Dictionary)
signal player_sid(sid: int)

func emit_player_states(states: Dictionary): player_states.emit(states)
func emit_player_sid(sid: int): player_sid.emit(sid)
