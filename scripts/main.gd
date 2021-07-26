extends Node2D

## WHAT THIS SCRIPT DOES
#process player input
#control turn system
#facilitate interaction between entities in world

### CONSTANTS ###

# the length of the side of one tile on the map
# for reference
const tileSize = 32

### VARIABLES ###

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

### UTILITY FUNCTIONS ###

# convert map coordinates to screen coordinates
func map2screen(pos):
	return Vector2(int(pos.x/tileSize), int(pos.y/tileSize))

# convert screen coordinates to map coordinates
func screen2map(pos):
	return Vector2(pos.x*32, pos.y*32)



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
