class_name InstantEvent

var _ev_name: String

var _last := 0
var _is_pending := false

func _init(ev_name: String):
	_ev_name = ev_name

func current() -> bool:
	if _is_pending:
		_is_pending = false
		return true
	return false

func listen(states: Dictionary, sid: int):
	if !states.has(sid) or !(states[sid] as Dictionary).has(_ev_name): return
	var val: int = states[sid][_ev_name]

	if val == 1 and _last == 0:
		_is_pending = true	
	_last = val
	
