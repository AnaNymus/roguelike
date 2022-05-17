extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var rng

var mind
var sight
var start


var dir1
var dir2

# Called when the node enters the scene tree for the first time.
func _ready():
	get_viewport().connect("size_changed", self, "resized")
	
	sight = self.get_node("bg/sight")
	mind = self.get_node("bg/mind")
	
	rng = RandomNumberGenerator.new()
	rng.randomize()
	
	dir1 = Vector2(rng.randi_range(-10, 10), rng.randi_range(-10, 10))
	dir2 = Vector2(rng.randi_range(-10, 10), rng.randi_range(-10, 10))


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func resized():
	var width = get_viewport().get_size().x
	var height = get_viewport().get_size().y
	
	self.get_node("bg").scale = Vector2(width/2560, height/1440)
	


func _on_start_pressed():
	get_tree().change_scene("res://scenes/main.tscn")


func _physics_process(delta):
	sight.offset += dir1 * delta
	mind.offset += dir2 * delta
	
	if sight.offset.x < -30:
		sight.offset.x = -30
	elif sight.offset.x > 30:
		sight.offset.x = 30
	
	if sight.offset.y < -30:
		sight.offset.y = -30
	elif sight.offset.y > 30:
		sight.offset.y = 30
		
	if mind.offset.x < -30:
		mind.offset.x = -30
	elif mind.offset.x > 30:
		mind.offset.x = 30
	
	if mind.offset.y < -30:
		mind.offset.y = -30
	elif mind.offset.y > 30:
		mind.offset.y = 30
	
	
	if(rng.randi()%100 == 0):
		dir1 = Vector2(rng.randi_range(-10, 10), rng.randi_range(-10, 10))
	if(rng.randi()%100 == 0):
		dir2 = Vector2(rng.randi_range(-10, 10), rng.randi_range(-10, 10))
	
	
	
