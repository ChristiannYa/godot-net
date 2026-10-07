class_name PlayerUtils
extends RefCounted

var net: PlayerUtilsNet
var visuals: PlayerUtilsVisuals

func _init(player: Player):
	net = PlayerUtilsNet.new(player)
	visuals = PlayerUtilsVisuals.new(player)
