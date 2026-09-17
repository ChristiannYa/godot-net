extends Node

@onready var player: PlayerRemote = self.get_parent()

func _ready():
	_set_sid_label.call_deferred()

func _set_sid_label():
	player.sid_label.text = "sid=%d" % player.sid
