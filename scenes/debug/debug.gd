extends Control

const _MAX_LINES := 200

@onready var log_label: RichTextLabel = $Sections/PanelContainer/ScrollContainer/LogLabel

var _lines: Array[String] = []

var _logging = Logging.new()

func _ready() -> void:
	SignalHub.player_states_live_sig.connect(_on_player_states_live)
	SignalHub.player_spawn_loc_sig.connect(_on_player_loc)

func _on_player_states_live(states: Dictionary):
	_handle_log("states=%s" % states)

func _on_player_loc(loc: Vector3):
	_handle_log("spawn_loc=%s" % loc)

func _handle_log(msg: Variant):
	var color = _logging.get_color(Logging.LogLevel.INFO)
	var timestamp := Time.get_time_string_from_system()
	_lines.append("[color=%s][%s] %s[/color]" % [color, timestamp, msg])

	if _lines.size() > _MAX_LINES: _lines.pop_front()

	log_label.text = "\n".join(_lines)
