class_name PlayerUtilsNetInterp
extends PlayerUtilsProvider

const _DELAY_MS := 100
const _SNAPSHOT_HZ := 60
const _BURST_ALLOWANCE := 10

var _history := (
	SnapshotHistory
	. new(
		# Snapshots inside the delay window, plus room for a burst
		int(_DELAY_MS * _SNAPSHOT_HZ / 1000.0) + _BURST_ALLOWANCE
	)
)


func push_server_loc(states: Dictionary, ss_time_s: float):
	var loc: XZ = p.utils.net.movement.get_server_pos(states)
	if loc == null:
		return

	_history.push(Snapshot.new(ss_time_s, loc.x, loc.z))


## Runs each frame, drawing a delayed player's position
func apply():
	# Moment in the past being shown on the screen (now - delay)
	var render_t: float = _now_s() - _DELAY_MS / 1000.0

	var pos: XZ = _history.pos_at(render_t)
	if pos == null:
		return

	p.global_position.x = pos.x
	p.global_position.z = pos.z


func _now_s() -> float:
	return Time.get_ticks_usec() / 1_000_000.0
