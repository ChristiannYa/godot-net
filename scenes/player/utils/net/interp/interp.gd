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
	var pose: Player.Pose = p.utils.net.movement.get_server_pose_or_null(
		states
	)
	if pose == null:
		return

	var ss: Snapshot = Snapshot.new(ss_time_s, pose)

	_history.push(ss)


## Runs each frame, drawing a delayed player's position
func apply():
	# Moment in the past being shown on the screen (now - delay)
	var render_t: float = UTime.now_s() - _DELAY_MS / 1000.0

	var pose: Player.Pose = _history.pose_at_or_null(render_t)
	if pose == null:
		return

	p.set_pose(pose, Player.YawSource.SERVER)
