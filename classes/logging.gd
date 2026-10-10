class_name Logging
extends Node

enum LogLevel { INFO, WARN, ERROR }


## Returns one of: white, yellow, red
func get_color(lvl: LogLevel) -> String:
	var color: String = ""
	match lvl:
		LogLevel.INFO:
			color = "white"
		LogLevel.WARN:
			color = "yellow"
		LogLevel.ERROR:
			color = "red"
	return color


func log(msg: String):
	var unix_time: float = Time.get_unix_time_from_system()
	var ms: int = (unix_time - int(unix_time)) * 1000
	var time = Time.get_time_string_from_system()
	print("[%s.%03d] %s" % [time, ms, msg])
