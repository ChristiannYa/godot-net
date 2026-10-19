class_name UdpRecvr

const _BITS_LEN := 8

var _peer: PacketPeerUDP
var _data: PktRecvData
var _ack: PktRecvAck


func _init(
	udp_peer: PacketPeerUDP,
	rel: UdpReliable,
):
	_peer = udp_peer
	_ack = PktRecvAck.new(rel)
	_data = PktRecvData.new(rel)


var _snapshot: PktRecvSnapshot = PktRecvSnapshot.new()


func recv(pkt: PackedByteArray):
	## Too short to hold the header
	if pkt.size() < 2:
		return

	match pkt[0]:
		UdpCodec.PKT_ACK:
			_ack.recv(pkt)

		UdpCodec.PKT_DATA:
			_data.recv(pkt)

		UdpCodec.PKT_SNAPSHOT:
			_snapshot.recv(pkt)
