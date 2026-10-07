class_name PlayerUtilsNet
extends RefCounted

var movement: PlayerUtilsNetMovement

func _init(player: Player):
	movement = PlayerUtilsNetMovement.new(player)
