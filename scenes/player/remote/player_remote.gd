class_name PlayerRemote
extends Player

func _ready():
	SignalHub.player_states_live_sig.connect(self.utils.net.movement.apply_server_loc)

