class_name NetState
extends RefCounted

## session id -> TRUE
var _synced_sids: Dictionary = {}

## session id -> { field name -> value, ... }
var _players: Dictionary = {}


## Initializes player state and marks it as synced
func reg_player(sid: int, is_sync: bool):
	if !_players.has(sid):
		_players[sid] = {}
		if is_sync:
			_synced_sids[sid] = true


func save_field(sid: int, field_name: String, value):
	_players[sid][field_name] = value


func players() -> Dictionary:
	return _players


func is_synced(sid: int) -> bool:
	return _synced_sids.has(sid)
