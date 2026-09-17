class_name PlayerRemote
extends Player

@onready var sid_label: Label3D = $SidLabel

func _ready():
	self.player_color = Color.from_hsv(
		randf(), 
		randf_range(0.6, 1.0), 
		randf_range(0.7, 1.0)
	)
	super._ready()
