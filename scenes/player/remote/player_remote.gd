class_name PlayerRemote
extends Player

var _is_crouching := false

var _jump_ev: = InstantEvent.new("IsJumping")

func _ready():
	super._ready();
	SignalHub.player_states_live_sig.connect(_on_player_states_live)

func _physics_process(delta: float):
	super._physics_process(delta)

func _wants_to_jump() -> bool: return _jump_ev.current()

func _wants_to_crouch() -> bool:
	return _is_crouching

func _on_player_states_live(states: Dictionary):
	_jump_ev.listen(states, sid)
	_handle_crouch_listener(states)

func _handle_crouch_listener(states: Dictionary):
	if states.get(sid).get("IsCrouching") == 1:
		_is_crouching = true
	else:
		_is_crouching = false


