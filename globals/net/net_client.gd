extends Node

const _BITS_LEN := 8

var _peer := PacketPeerUDP.new()

var schema := GdPacketSchema.create()

## session id -> sequence number
var _last_seq: Dictionary = {}

## session id -> TRUE
var _synced_sids: Dictionary = {}

## session id -> { field name -> value, ... }
var _player_states: Dictionary = {}

func _ready():
	_peer.bind(0)
	_peer.set_dest_address("10.0.0.4", 34254)
	_ping()

func _process(_delta: float):
	while _peer.get_available_packet_count() > 0:
		var raw_pkt = _peer.get_packet()
		if raw_pkt.is_empty(): continue

		match raw_pkt[0]:
			GdPacketSchema.PACKET_KIND_SINGLE:		
				_handle_pkt(schema.decode(raw_pkt.slice(1)), false)
			GdPacketSchema.PACKET_KIND_BATCH:
				var records: Array = schema.decode_batch(raw_pkt.slice(1))
				for pkt in records:
					_handle_pkt(pkt, true)

		SignalHub.emit_player_states_live(_player_states)

## `pkt`: field name -> value
func _handle_pkt(pkt: Dictionary, is_sync: bool):
	var sid: int = pkt.get("SessionId")

	if pkt.has("Sequence"):
		var seq: int = pkt["Sequence"]
		if _last_seq.has(sid) and !_is_seq_new(seq, _last_seq[sid]):	
			return # Dropped: stale/out-of-order packet
		_last_seq[sid] = seq

	if pkt.has("IsNewPlayer"):
		SignalHub.player_sid_sig.emit(sid)

	if !_player_states.has(sid):
		_player_states[sid] = {}
		if is_sync:
			_synced_sids[sid] = true


	for field_name in pkt:
		if field_name not in ["IsNewPlayer", "SessionId", "Sequence"]:
			_player_states[sid][field_name] = pkt[field_name]

func _ping(): self.send_input("Ping", 1)

func is_synced(sid: int) -> bool:
	return _synced_sids.has(sid)

func send_input(field_name: String, value: int):
	var packet = schema.encode({field_name: value})
	_peer.put_packet(packet)

## Returns true if `seq` is more recent than `last_seq`, treating both as a
## circular counter that wraps at 2^`_BITS_LEN`.
## This correctly handles wraparound (e.g. 0 counts as newer than 255) while
## still rejecting genuinely stale/out-of-order packets.
func _is_seq_new(seq: int, last_seq: int) -> bool:
	var bits_max: int = 1 << _BITS_LEN
	var diff: int = (seq - last_seq + bits_max) % bits_max
	return diff != 0 and diff < (bits_max >> 1)
