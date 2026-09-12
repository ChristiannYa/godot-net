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
		var raw_pkt = _peer.get_packet()
		if raw_pkt.is_empty(): continue

		match raw_pkt[0]:
			GdPacketSchema.PACKET_KIND_SINGLE:		
				_handle_pkt(_schema.decode(raw_pkt.slice(1)))
			GdPacketSchema.PACKET_KIND_BATCH:
				var records: Array = _schema.decode_batch(raw_pkt.slice(1))
				for pkt in records:
					_handle_pkt(pkt)

		SignalHub.emit_player_states(player_states)

## `pkt`: field name -> value
func _handle_pkt(pkt: Dictionary):
	var sid: int = pkt.get("SessionId")

	if pkt.has("Sequence"):
		var seq: int = pkt["Sequence"]
		if _last_seq.has(sid) and !_is_seq_new(seq, _last_seq[sid]):	
			return # Dropped: stale/out-of-order packet
		_last_seq[sid] = seq

	if pkt.has("IsNewClient"):
		SignalHub.player_sid_sig.emit(sid)

	if !player_states.has(sid):
		player_states[sid] = {}

	for field_name in pkt:
		if field_name not in ["IsNewClient", "SessionId", "Sequence"]:
			player_states[sid][field_name] = pkt[field_name]

## Returns true if `seq` is more recent than `last_seq`, treating both as a
## circular counter that wraps at 2^`_BITS_LEN`.
## This correctly handles wraparound (e.g. 0 counts as newer than 255) while
## still rejecting genuinely stale/out-of-order packets.
func _is_seq_new(seq: int, last_seq: int) -> bool:
	var bits_max: int = 1 << _BITS_LEN
	var diff: int = (seq - last_seq + bits_max) % bits_max
	return diff != 0 and diff < (bits_max >> 1)
