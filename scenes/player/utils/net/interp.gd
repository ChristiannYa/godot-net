class_name PlayerUtilsNetInterp
extends PlayerUtilsProvider

## How far in the past remote players are drawn
const _DELAY_MS := 100

const _HISTORY := 16

var _l: Logging = Logging.new()

## Oldest first: [{ "t": seconds, "x": float, "z": float }, ...]
var _history: Array[Dictionary] = []

var _stat_t := 0.0
var _stat_count := 0
var _stat_max_gap := 0.0
var _stat_slow := 0

func push_server_loc(states: Dictionary):
	var state: Dictionary = states.get(p.sid, {})
	if !state.has("LocationX") or !state.has("LocationZ"): return

	var loc: Vector3 = UdpSkt.udp_codec.decode_loc(
		state["LocationX"],
		state["LocationZ"]
	)
	_history.append({
		"t": Time.get_ticks_usec() / 1_000_000.0,
		"x": loc.x,
		"z": loc.z,
	})
	if _history.size() > _HISTORY: _history.pop_front()

	# TEMPORARY: remove after test
	if _history.size() >= 2:
		var now: float = _history[-1]["t"]
		var gap: float = now - _history[-2]["t"]
		_stat_count += 1
		_stat_max_gap = maxf(_stat_max_gap, gap)
		if gap > 0.04: _stat_slow += 1
		if now - _stat_t >= 1.0:
			_l.log("snaps=%d max_gap=%.0f ms slow=%d" % [_stat_count, _stat_max_gap * 1000.0, _stat_slow])
			_stat_t = now
			_stat_count = 0
			_stat_max_gap = 0.0
			_stat_slow = 0


func apply():
	if _history.is_empty(): return

	var render_t: float = Time.get_ticks_usec() / 1_000_000.0 - _DELAY_MS / 1000.0
	var first: Dictionary = _history[0]
	var last: Dictionary = _history[-1]

	# No snapshot old enough or new enough: hold the nearest one
	if render_t <= first["t"]: return _place(first["x"], first["z"])
	if render_t >= last["t"]: return _place(last["x"], last["z"])

	# Find the two snapshots around render_t and slide between them
	for i in range(_history.size() - 1):
		var a: Dictionary = _history[i]
		var b: Dictionary = _history[i + 1]
		if render_t > b["t"]: continue

		var span: float = b["t"] - a["t"]
		var w: float = (render_t - a["t"]) / span if span > 0.0 else 1.0
		return _place(lerpf(a["x"], b["x"], w), lerpf(a["z"], b["z"], w))

func _place(x: float, z: float):
	p.global_position.x = x
	p.global_position.z = z
