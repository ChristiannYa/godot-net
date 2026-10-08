class_name PlayerUtilsNet
extends RefCounted

var movement: PlayerUtilsNetMovement
var interp: PlayerUtilsNetInterp

func _init(player: Player):
	movement = PlayerUtilsNetMovement.new(player)
	interp = PlayerUtilsNetInterp.new(player)
