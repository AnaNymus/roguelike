extends Node2D


var pos = Vector2(1, 1)
var tileSize

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# store tileSize here so we can reference it easily later
	tileSize = self.get_parent().tileSize


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
