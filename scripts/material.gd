extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var type = "random_item"
var pocket = "material"
var flavor_text = "blank"
var tags = []
var throwing_damage = 1

var small_sprite = "res://sprites/item.png"
var large_sprite = "res://sprites/item.png"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_item_type(t):
	type = t
	# TODO: change item sprite

func set_small_sprite(t):
	small_sprite = t
	self.get_node("Sprite").texture = load(small_sprite)

func set_large_sprite(t):
	large_sprite = t

func set_flavor(t):
	flavor_text = t

func add_tag(t):
	tags.append(t)
	
func set_damage(d):
	throwing_damage = d
