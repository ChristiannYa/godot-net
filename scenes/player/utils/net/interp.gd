class_name PlayerUtilsNetInterp
extends PlayerUtilsProvider

const _DELAY_MS := 100
const _SNAPSHOT_HZ := 60

## Snapshots that may arrive at once after a stall
const _BURST_ALLOWANCE := 10

## Snapshots inside the delay window, plus room for a burst
@warning_ignore("integer_division")
const _HISTORY := _DELAY_MS * _SNAPSHOT_HZ / 1000 + _BURST_ALLOWANCE

class Snapshot:
	var t: float
	var x: float
	var z: float

	func _init(t_: float, x_: float, z_: float) -> void:
		t = t_; x = x_; z = z_

var _history: Array[Snapshot] = []

func push_server_loc(states: Dictionary):
	var state: Dictionary = states.get(p.sid, {})
	if !state.has("LocationX") or !state.has("LocationZ"): return

	var loc: Vector3 = UdpSkt.udp_codec.decode_loc(
		state["LocationX"],
		state["LocationZ"]
	)
	_history.append(Snapshot.new(
		Time.get_ticks_usec() / 1_000_000.0,
		loc.x,
		loc.z
	))
	if _history.size() > _HISTORY: _history.pop_front()

## Runs each frame, drawing a delayed player's position
func apply():
	if _history.is_empty(): return

	# Moment in the past being shown on the screen (now - delay)
	var render_t: float = Time.get_ticks_usec() / 1_000_000.0 - _DELAY_MS / 1000.0

	var oldest: Snapshot = _history[0]
	var newest: Snapshot = _history[-1]

	# No snapshot old enough or new enough: hold the nearest one
	if render_t <= oldest.t: return _place(oldest.x, oldest.z)
	if render_t >= newest.t: return _place(newest.x, newest.z)

	# Find the 2 snapshots around render_t and slide between them
	for i in range(_history.size() - 1):
		var l: Snapshot = _history[i]
		var r: Snapshot = _history[i + 1]
		if render_t > r.t:
			# This pair is entirely before render_t, so try the next one
			continue

		var elapsed: float = r.t - l.t

		# Fraction of the way from l to r
		# `render_t - l.t` = time since the older snapsthot
		var w: float = (render_t - l.t) / elapsed if elapsed > 0.0 else 1.0

		return _place(lerpf(l.x, r.x, w), lerpf(l.z, r.z, w))

func _place(x: float, z: float):
	p.global_position.x = x
	p.global_position.z = z
