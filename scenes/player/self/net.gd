extends Node

@onready var player: PlayerSelf = self.get_parent()

func _ready():
	SignalHub.player_states_live_sig.connect(_on_player_states_live)

func _physics_process(_delta: float):
	UdpSkt.send_intent(Input.get_vector("m_left", "m_right", "m_fwd", "m_back"))

func _on_player_states_live(states: Dictionary):
	var state: Dictionary = states.get(player.sid, {})
	if !state.has("LocationX") or !state.has("LocationZ"): return

	var loc: Vector3 = UdpSkt.udp_codec.decode_loc(
		state["LocationX"], 
		state["LocationZ"]
	)
	player.global_position.x = loc.x
	player.global_position.z = loc.z
