class_name PlayerUtils
extends RefCounted

var net: PlayerUtilsNet

func _init(player: Player):
	net = PlayerUtilsNet.new(player)
