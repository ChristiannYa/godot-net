class_name PacketHandler

var _udp_peer: PacketPeerUDP
var _udp_codec: UdpCodec
var _clock := ServerClock.new()
var _state: NetState
var _rel: NetReliable

# TMP
var _last_ss_t := 0.0


func _init(
	udp_peer: PacketPeerUDP,
	udp_codec: UdpCodec,
	state: NetState,
	rel: NetReliable,
):
	_udp_peer = udp_peer
	_udp_codec = udp_codec
	_state = state
	_rel = rel


func ack(raw_pkt: PackedByteArray):
	var id: int = UdpAck.decode_ack(raw_pkt)
	if id != -1:
		_rel.handle_ack(id)


func data(raw_pkt: PackedByteArray):
	match raw_pkt[1]:
		UdpCodec.DEC_SINGLE:
			_handle_pkt(_udp_codec.decode(raw_pkt), false)
		UdpCodec.DEC_BATCH:
			var records: Array = _udp_codec.decode_batch(raw_pkt)
			for pkt in records:
				_handle_pkt(pkt, true)

	SignalHub.emit_player_states_live(_state.player_states())


func snapshot(raw_pkt: PackedByteArray):
	var ss: Dictionary = _udp_codec.decode_snapshot(raw_pkt)
	if ss.is_empty():
		return

	var now_s := _now_s()
	if !_clock.accept(ss["tick"], now_s):
		return
	var ss_t := _clock.cur_ss_time()

	# TMP: the gap between snapshot times should be an even 16.7 ms
	if _last_ss_t > 0.0:
		print("snap gap: %.1f ms" % ((ss_t - _last_ss_t) * 1000.0))
	_last_ss_t = ss_t

	for pkt: Dictionary in ss["records"]:
		_handle_pkt(pkt, true)
	SignalHub.emit_player_snapshot_sig(_state.player_states())

	# A controlled player is also moved by this signal. Skipping it would
	# freeze the player
	SignalHub.emit_player_states_live(_state.player_states())


## `pkt`: field name -> value
func _handle_pkt(raw_pkt: Dictionary, is_sync: bool):
	var sid: int = raw_pkt.get("DevSessionId")

	# Dropped: stale/out-of-order packet
	if !_state.accept_seq(sid, raw_pkt):
		return

	if raw_pkt.has("DevPacketId"):
		var pkt_id: int = raw_pkt["DevPacketId"]
		_udp_peer.put_packet(UdpAck.encode_ack(pkt_id))
		if _rel.is_pkt_seen(pkt_id):
			return  # No need to re-process packet

	if raw_pkt.has("DevIsNewPlayer"):
		SignalHub.emit_player_sid(sid)

	_state.reg_player(sid, is_sync)

	for field_name: String in raw_pkt:
		if !field_name.begins_with("Dev"):
			_state.save_field(sid, field_name, raw_pkt[field_name])


func _now_s() -> float:
	return Time.get_ticks_usec() / 1_000_000.0
