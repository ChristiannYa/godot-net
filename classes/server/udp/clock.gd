class_name ServerClock

const _TICK_DT := 1.0 / 60.0

## Newest tick see, counted past the 2-byte wrap.
## -1 until the first snapshot arrives
var _tick := -1

## Best estimate so far of (client clock - server clock), in seconds
var _offset := 0.0


## Returns false for a snapshot that is not newer than the lst one (duplicate
## or reordered), so the caller can drop it
func accept(tick: int, arrival_s: float) -> bool:
	# 1st snapshot: nothing to compare with yet
	if _tick < 0:
		_tick = tick
		_offset = arrival_s - _tick * _TICK_DT
		return true

	# How many ticks ahead of the newest one is this snapshot?
	# the 2-byte number is treated like a clock face, so 65535 -> 0 counts
	# as +1
	var delta := (tick - _tick) & 0xFFFF
	if delta >= 0x8000:
		delta -= 0x10000

	# Same tick or older: drop it
	if delta <= 0:
		return false

	_tick += delta

	# This packet's estimate of the offset. Keep it only if it is lower than
	# the best one so far
	var est := arrival_s - _tick * _TICK_DT
	_offset = minf(_offset, est)
	return true


## The newest accepted snapshot's time, on the client's clock, in seconds
func cur_ss_time() -> float:
	return _tick * _TICK_DT + _offset
