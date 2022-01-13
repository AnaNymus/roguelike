extends Node

# character direction codes
const FRONT = 0
const FRONT_LEFT = 1
const LEFT = 2
const BACK_LEFT = 3
const BACK = 4
const BACK_RIGHT = 5
const RIGHT = 6
const FRONT_RIGHT = 7

# vectors corresponding to each of the above direction codes
const DIR = [Vector2(0, 1), Vector2(-1, 1), Vector2(-1, 0), Vector2(-1, -1), Vector2(0, -1), Vector2(1, -1), Vector2(1, 0), Vector2(1, 1)]


const tileSize = 32
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

## These lists hold the names of items and an instance of them
# so that their effects, flavor text, etc. can be referenced
var botannical = {}
var material = {}
var weapon = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	## TODO: eventually, items will be randomly generated
	# but for now we'll describe a couple
	var i = preload("res://scenes/botannical.tscn")
	
	# apple: restores hp
	var a = i.instance()
	a.set_item_type("apple")
	a.set_flavor("A juicy red apple. It looks perfectly ripe.")
	a.set_effect("restore hunger")
	a.set_small_sprite("res://sprites/apple.png")
	a.set_large_sprite("res://sprites/apple_large.png")
	botannical["apple"] = a
	
	var d = i.instance()
	d.set_item_type("dandelion")
	d.set_flavor("A bright yellow weed. It smells faintly floral.")
	d.set_effect("restore hp")
	a.set_small_sprite("res://sprites/dandelion.png")
	d.set_large_sprite("res://sprites/dandelion_large.png")
	botannical["dandelion"] = d
	
	var f = i.instance()
	f.set_item_type("fern")
	f.set_flavor("A feathery-looking leaf. It has small spores on the underside.")
	f.set_effect("none")
	a.set_small_sprite("res://sprites/fern.png")
	f.set_large_sprite("res://sprites/fern_large.png")
	botannical["fern"] = f
	
	i = preload("res://scenes/material.tscn")
	
	var s = i.instance()
	s.set_item_type("stick")
	s.set_flavor("It's just a stick.")
	s.set_large_sprite("res://sprites/stick_large.png")
	s.set_small_sprite("res://sprites/stick.png")
	material["stick"] = s
	
	var r = i.instance()
	r.set_item_type("rock")
	r.set_flavor("A fist-sized rock. It has a good weight to it.")
	r.set_damage(5)
	r.add_tag("thrown")
	r.set_small_sprite("res://sprites/rock.png")
	r.set_large_sprite("res://sprites/rock_large.png")
	material["rock"] = r
	



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
