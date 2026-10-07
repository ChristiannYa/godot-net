class_name PlayerUtils
extends Node

@onready var net: PlayerUtilsNet

func _init(player: Player):
	net = PlayerUtilsNet.new(player)
