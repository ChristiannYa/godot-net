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

	var y: Variant = p.utils.net.movement.get_server_y(states)
	if y == null:
		return

	var is_crouching: Variant = p.utils.net.movement.get_server_crouch(states)
	if is_crouching == null:
		return

	var yaw: float = p.utils.net.movement.get_server_yaw(states)

	var pose: Pose = Pose.new(loc.x, y, loc.z, yaw, is_crouching)
	var ss: Snapshot = Snapshot.new(ss_time_s, pose)
	_history.push(ss)


## Runs each frame, drawing a delayed player's position
func apply():
	# Moment in the past being shown on the screen (now - delay)
	var render_t: float = UTime.now_s() - _DELAY_MS / 1000.0

	var pose: Pose = _history.pose_at(render_t)
	if pose == null:
		return

	## @TODO: Make a function that receives and applies the pose
	p.global_position.x = pose.x
	p.global_position.y = pose.y
	p.global_position.z = pose.z
	p.face(pose.yaw)
	p.set_is_crouching(pose.is_crouching)
