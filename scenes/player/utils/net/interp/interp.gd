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


func push_server_pose(states: Dictionary, ss_time_s: float):
	var loc: XZ = p.utils.net.movement.get_server_pos(states)
	if loc == null:
		return

	var yaw: float = p.utils.net.movement.get_server_yaw(states)
	_history.push(Snapshot.new(ss_time_s, loc.x, loc.z, yaw))


## Runs each frame, drawing a delayed player's position
func apply():
	# Moment in the past being shown on the screen (now - delay)
	var render_t: float = _now_s() - _DELAY_MS / 1000.0

	var pose: Pose = _history.pose_at(render_t)
	if pose == null:
		return

	p.global_position.x = pose.x
	p.global_position.z = pose.z
	p.rotation.y = pose.yaw


func _now_s() -> float:
	return Time.get_ticks_usec() / 1_000_000.0
