extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var direction = "up"
var type = "stairs"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func setas_up():
	direction = "up"
	self.get_node("Sprite").texture = load("res://sprites/up_stairs.png")

func setas_down():
	direction = "down"
	self.get_node("Sprite").texture = load("res://sprites/down_stairs.png")
