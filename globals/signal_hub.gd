extends Node

signal player_log_sig(msg: String, lvl: Logging.LogLevel)

func emit_player_log_sig(msg: String, lvl: Logging.LogLevel = Logging.LogLevel.INFO): player_log_sig.emit(msg, lvl)
