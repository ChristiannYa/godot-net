class_name PlayerRemote
extends Player

@onready var sid_label: Label3D = $SidLabel

func _ready():
	super._ready()
	_set_sid_label.call_deferred()

func _set_sid_label():
	sid_label.text = "sid=%d" % sid
