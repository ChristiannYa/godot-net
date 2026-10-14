class_name UTime


static func now_s() -> float:
	return Time.get_ticks_usec() / 1_000_000.0
