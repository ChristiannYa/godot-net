class_name NetState
extends RefCounted

const _BITS_LEN := 8

## session id -> sequence number
var _last_seq: Dictionary = {}

## session id -> TRUE
var _synced_sids: Dictionary = {}

## session id -> { field name -> value, ... }
var _players: Dictionary = {}


## Returns false if the packet is stale/out-of-order and should be dropped.
## Updates the stored sequence as a side effect when accepted.
func accept_seq(sid: int, pkt: Dictionary) -> bool:
	if !pkt.has("DevSequence"):
		return true
	var seq: int = pkt["DevSequence"]
	if !_is_seq_new(sid, seq):
		return false  # stale/out-of-order

	_last_seq[sid] = seq
	return true


## Returns true if `seq` is more recent than `last_seq`, treating both as a
## circular counter that wraps at 2^`_BITS_LEN`.
## This correctly handles wraparound (e.g. 0 counts as newer than 255) while
## still rejecting genuinely stale/out-of-order packets.
func _is_seq_new(sid: int, seq: int) -> bool:
	if !_last_seq.has(sid):
		return true  # First ever packet from this player
	var last_seq: int = _last_seq[sid]

	var bits_max: int = 1 << _BITS_LEN
	var diff: int = (seq - last_seq + bits_max) % bits_max
	return diff != 0 and diff < (bits_max >> 1)


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
