extends Node

const _BITS_LEN := 8

var _peer := PacketPeerUDP.new()

var _schema := GdPacketSchema.create()
var _last_seq := {}

func _ready():
	_peer.bind(0)
	_peer.set_dest_address("10.0.0.4", 34254)

func send_input(field_name: String, value: int):
	var packet = _schema.encode({field_name: value})
	_peer.put_packet(packet)

func _process(_delta: float):
	while _peer.get_available_packet_count() > 0:
		var fields: Dictionary = _schema.decode(_peer.get_packet())
		var sess_id: int = fields.get("SessionId")
		var seq: int = fields.get("Seq")

		if _last_seq.has(sess_id) and !_is_newer(seq, _last_seq[sess_id]):
			# Dropped: stale/out-of-order packet
			continue

		_last_seq[sess_id] = seq
		print("@Server: ", fields)

func _is_newer(seq: int, last: int) -> bool:
	var bits_max: int = 1 << _BITS_LEN
	var diff: int = (seq - last + bits_max) % bits_max
	return diff != 0 and diff < (bits_max >> 1)

