extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var map


# Called when the node enters the scene tree for the first time.
func _ready():
	map = self.get_node("TileMap")
	generate_map(Vector2(20, 20))


# generate map of size sz
func generate_map(sz):
	
	for x in range(sz.x):
		for y in range(sz.y):
			map.set_cellv(Vector2(x, y), 1)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
