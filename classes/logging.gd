class_name Logging
extends Node

enum LogLevel { INFO, WARN, ERROR }

## Returns one of: white, yellow, red
func get_color(lvl: LogLevel) -> String:
	var color: String = ""
	match lvl:
		LogLevel.INFO: color = "white"
		LogLevel.WARN: color = "yellow"
		LogLevel.ERROR: color = "red"
	return color
