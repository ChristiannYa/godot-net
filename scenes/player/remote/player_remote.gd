class_name PlayerRemote
extends Player

var _l: Logging = Logging.new()

var _last_jump_val := 0
var _pending_jump := false

var _is_crouching := false

var _jump_ct := 0
var _pos_vel_ct := 0
var _was_rising := false

func _ready():
	super._ready();
	SignalHub.player_states_live_sig.connect(_on_player_states_live)

func _physics_process(delta: float):
	super._physics_process(delta)

	var rising := self.velocity.y > 0.0
	if rising and !_was_rising:
		_pos_vel_ct += 1
		_l.log("rem_sid=%d, pos_vel_ct=%d" % [sid, _pos_vel_ct])
	_was_rising = rising

func _sync_jump():
	var states: Dictionary = UdpSkt.player_states()
	if states.has(sid) and (states[sid] as Dictionary).has("IsJumping"):
		_last_jump_val = states[sid]["IsJumping"]

func _wants_to_jump() -> bool:
	if _pending_jump:
		_pending_jump = false
		_jump_ct += 1
		_l.log("rem_sid=%d, jump_ct=%d, on_floor=%s" % [sid, _jump_ct, is_on_floor()])
		return true
	return false

func _wants_to_crouch() -> bool:
	return _is_crouching

func _on_player_states_live(states: Dictionary):
	_handle_jump_listener(states)
	_handle_crouch_listener(states)

func _handle_jump_listener(states: Dictionary):
	if !states.has(sid) or !(states[sid] as Dictionary).has("IsJumping"): return
	var val: int = states[sid]["IsJumping"]

	if val == 1 and _last_jump_val == 0:
		_pending_jump = true

	_last_jump_val = val

func _handle_crouch_listener(states: Dictionary):
	if states.get(sid).get("IsCrouching") == 1:
		_is_crouching = true
	else:
		_is_crouching = false


