class_name NetReliable
extends RefCounted

var _udp_pending := UdpPending.create()
var _udp_dedup := UdpDedup.create()

## Seeds `DevPacketId` into `fields` before `encode()`, and tracks the
## resulting bytes for retry.
## Returns the encoded bytes to send_input.
func send_input(fields: Dictionary, encode: Callable) -> PackedByteArray:
	var id: int = _udp_pending.next_id()
	fields["DevPacketId"] = id

	var bytes: PackedByteArray = encode.call(fields)
	_udp_pending.track(id, bytes)
	return bytes

## Call on receiving an ack packet. Removes the matching pending entry.
func handle_ack(id: int):
	_udp_pending.ack(id)

## Returns true if this is the first time `id` is seen; false if duplicate.
## Marks `id` as seen regardless of `is_seen`'s result.
func is_pkt_seen(id: int):
	var is_seen := _udp_dedup.is_seen(id)
	_udp_dedup.mark_seen(id)
	return is_seen

## Call once per tick.
## Sweeps dedups's own timestamps as a side effect.
## Returns the raw bytes of every packet due for resend (caller is responsible
## for actually sending them).
func tick() -> Array[PackedByteArray]:
	_udp_dedup.sweep()
	return _udp_pending.due_retry()
