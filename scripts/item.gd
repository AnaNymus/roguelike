extends Node2D

## THIS IS JUST TO DISPLAY ITEMS ON THE MAP
## THERE WILL BE MORE DETAILED ITEM OBJECTS FOR DESCRIBING WHAT THEY DO
## BUT WE DON'T NEED A MILLION INSTANCES OF THAT INFO


var type = "random_item"
var pocket = "botannical"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_item_type(t):
	type = t

func set_pocket(t):
	pocket = t

func set_sprite(t):
	self.get_node("Sprite").texture = load(t)
