class_name UdpReliable
extends RefCounted

var _pending := UdpPending.create()
var _dedup := UdpDedup.create()


## Seeds `DevPacketId` into `fields` before `encode()`, and tracks the
## resulting bytes for retry.
## Returns the encoded bytes to send_input.
func send_input(fields: Dictionary, encode: Callable) -> PackedByteArray:
	var id: int = _pending.next_id()
	fields["DevPacketId"] = id

	var bytes: PackedByteArray = encode.call(fields)
	_pending.track(id, bytes)
	return bytes


## Call on receiving an ack packet. Removes the matching pending entry.
func handle_ack(id: int):
	_pending.ack(id)


## Returns true if this is the first time `id` is seen; false if duplicate.
## Marks `id` as seen regardless of `is_seen`'s result.
func is_pkt_seen(id: int):
	var is_seen := _dedup.is_seen(id)
	_dedup.mark_seen(id)
	return is_seen


## Call once per tick.
## Sweeps dedups's own timestamps as a side effect.
## Returns the raw bytes of every packet due for resend (caller is responsible
## for actually sending them).
func tick() -> Array[PackedByteArray]:
	_dedup.sweep()
	return _pending.due_retry()
