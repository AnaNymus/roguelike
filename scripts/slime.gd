extends Node2D

var type = "slime"

var maxhp = 15
var currenthp = 15

var map

# Called when the node enters the scene tree for the first time.
func _ready():
	map = self.get_parent().get_parent().get_node("map")

func take_damage(dmg):
	currenthp -= dmg
	
	if currenthp <= 0:
		map.remove_enemy(map.get_parent().screen2map(self.position))
