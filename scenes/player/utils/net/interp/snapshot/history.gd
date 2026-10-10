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
func pose_at(at_t: float) -> Pose:
	if _snaps.is_empty():
		return null

	var oldest: Snapshot = _snaps[0]
	var newest: Snapshot = _snaps[-1]

	# No snapshot old enough or new enough: hold the nearest one
	if at_t <= oldest.t:
		return _of(oldest)
	if at_t >= newest.t:
		return _of(newest)

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
	return _of(newest)


static func _of(snap: Snapshot) -> Pose:
	return Pose.new(snap.x, snap.z, snap.yaw)


static func _blend(older: Snapshot, newer: Snapshot, at_t: float) -> Pose:
	var elapsed: float = newer.t - older.t

	# Fraction of the way from older to newer
	var w: float = (at_t - older.t) / elapsed if elapsed > 0.0 else 1.0

	return Pose.new(
		lerpf(older.x, newer.x, w),
		lerpf(older.z, newer.z, w),
		lerp_angle(older.yaw, newer.yaw, w)
	)
