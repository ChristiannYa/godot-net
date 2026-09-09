extends Node

signal player_log_sig(msg: String, lvl: Logging.LogLevel)
signal player_sid(sid: int)

func emit_player_log_sig(msg: String, lvl: Logging.LogLevel = Logging.LogLevel.INFO): player_log_sig.emit(msg, lvl)
func emit_player_sid(sid: int): player_sid.emit(sid)
