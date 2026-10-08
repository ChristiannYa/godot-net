class_name PlayerRemote
extends Player

func _ready():
	SignalHub.player_snapshot_sig.connect(utils.net.interp.push_server_loc)

func _process(_delta: float):
	utils.net.interp.apply()
