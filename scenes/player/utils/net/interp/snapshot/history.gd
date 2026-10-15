class_name SnapshotHistory

var _capacity: int

## Oldest first
var _snaps: Array[Snapshot] = []


func _init(capacity: int):
	_capacity = capacity


func push(snap: Snapshot):
	_snaps.append(snap)
	if _snaps.size() > _capacity:
		_snaps.pop_front()


## Pose (position + yaw direction) at time `at_t`, or null when there are no
## snapshots yet
func pose_at_or_null(at_t: float) -> Pose:
	if _snaps.is_empty():
		return null

	var oldest: Snapshot = _snaps[0]
	var newest: Snapshot = _snaps[-1]

	# No snapshot old enough or new enough: hold the nearest one
	if at_t <= oldest.t:
		return _of(oldest.pose)
	if at_t >= newest.t:
		return _of(newest.pose)

	# Find the 2 snapshots around at_t and slide between them
	for i in range(_snaps.size() - 1):
		var older: Snapshot = _snaps[i]
		var newer: Snapshot = _snaps[i + 1]

		# This pair is entirely before at_t, so try the next one
		if at_t > newer.t:
			continue

		return _blend(older, newer, at_t)

	# Unreachable, since the checks above guarantee a pair. GDScript still
	# wants every path to return something
	return _of(newest.pose)


static func _of(pose: Pose) -> Pose:
	return Pose.new(pose.x, pose.y, pose.z, pose.yaw, pose.is_crouching)


static func _blend(older: Snapshot, newer: Snapshot, at_t: float) -> Pose:
	var elapsed: float = newer.t - older.t

	# Fraction of the way from older to newer
	var w: float = (at_t - older.t) / elapsed if elapsed > 0.0 else 1.0

	return (
		Pose
		. new(
			lerpf(older.pose.x, newer.pose.x, w),
			lerpf(older.pose.y, newer.pose.y, w),
			lerpf(older.pose.z, newer.pose.z, w),
			lerp_angle(older.pose.yaw, newer.pose.yaw, w),
			# A bool can't be blended, so hold the older snapshot's value until
			# the newer one's time arrives
			older.pose.is_crouching
		)
	)
