extends Node

const _BITS_LEN := 8

var _peer := PacketPeerUDP.new()

var _schema := GdPacketSchema.create()

## session id -> sequence number
var _last_seq: Dictionary = {}

## session id -> { field name -> value, ... }
var player_states: Dictionary = {}

func _ready():
	_peer.bind(0)
	_peer.set_dest_address("10.0.0.4", 34254)

func send_input(field_name: String, value: int):
	var packet = _schema.encode({field_name: value})
	_peer.put_packet(packet)

func _process(_delta: float):
	while _peer.get_available_packet_count() > 0:
		## field name -> value
		var pkt: Dictionary = _schema.decode(_peer.get_packet())

		var sid: int = pkt.get("SessionId")

		## Fallsback to 0 if not found. This means that the player has joined
		## halfway through the session
		var seq: int = pkt.get("Sequence", 0)

		if _last_seq.has(sid) and !_is_newer(seq, _last_seq[sid]):
			# Dropped: stale/out-of-order packet
			continue
		_last_seq[sid] = seq

		if !player_states.has(sid):
			player_states[sid] = {}

		for field_name in pkt:
			if field_name != "SessionId" and field_name != "Sequence":
				player_states[sid][field_name] = pkt[field_name]

		SignalHub.emit_player_log_sig("(NetClient) player_states=%s" % player_states)

func _is_newer(seq: int, last: int) -> bool:
	var bits_max: int = 1 << _BITS_LEN
	var diff: int = (seq - last + bits_max) % bits_max
	return diff != 0 and diff < (bits_max >> 1)

