@tool
extends EditorScript

func _run() -> void:
	var schema = GdPacketSchema.create()
	var writer_test = { 
		"Health": 3,
		"PlayerCount": 4,
		"IsJumping": 1,
		"IsCrouching": 1,
		"IsFriendly": 1,
	}
	var packet = schema.encode(writer_test)
	print(packet)

	var decoded = schema.decode(packet)
	print(decoded)
