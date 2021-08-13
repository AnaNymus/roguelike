extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var type = "tree"

var maxhp = 10
var currenthp = 10

var map

# Called when the node enters the scene tree for the first time.
func _ready():
	map = self.get_parent().get_parent()

func take_damage(dmg):
	currenthp -= dmg
	
	if currenthp <= 0:
		map.remove_feature(map.get_parent().screen2map(self.position))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
