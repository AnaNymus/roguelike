extends Node2D

const FRONT = 0
const FRONT_LEFT = 1
const LEFT = 2
const BACK_LEFT = 3
const BACK = 4
const BACK_RIGHT = 5
const RIGHT = 6
const FRONT_RIGHT = 7

const hframes = 4

var type = "slime"

var maxhp = 15
var currenthp = 15

var map
var main
var sprite

# governs how the slime animates
# options are: idle, move, attack, death
var anim_mode = "idle"

# Called when the node enters the scene tree for the first time.
func _ready():
	map = self.get_parent().get_parent().get_node("map")
	main = self.get_parent().get_parent()
	sprite = self.get_node("Sprite")

func take_damage(dmg):
	currenthp -= dmg
	
	if currenthp <= 0:
		map.remove_enemy(map.get_parent().screen2map(self.position))

func take_turn():
	#TODO: make more complex
	move_random()

func animate():
	var resid = sprite.frame % hframes
	
	if anim_mode == "idle":
		if resid == 0:
			sprite.frame += 3
		else:
			sprite.frame -= 3
	elif anim_mode == "move":
		if resid == 3:
			sprite.frame -= 3
			anim_mode = "idle"
			##TODO end action
		else:
			sprite.frame += 1
	elif anim_mode == "attack":
		pass
	elif anim_mode == "die":
		pass


func move_random():
	
	var dir = randi()%8
	sprite.frame = dir*hframes
	anim_mode = "move"
	var pos = main.screen2map(self.position)
	print(pos)
	if dir == FRONT:
		if not map.check_midLevel(pos + Vector2(0, 1)):
			if map.check_pos(pos + Vector2(0, 1)):
				map.move_enemy(pos, pos + Vector2(0, 1))
				self.position = main.map2screen(pos + Vector2(0, 1))
	elif dir == FRONT_LEFT:
		if not map.check_midLevel(pos + Vector2(-1, 1)):
			if map.check_pos(pos + Vector2(-1, 1)):
				map.move_enemy(pos, pos + Vector2(-1, 1))
				self.position = main.map2screen(pos + Vector2(-1, 1))
	elif dir == LEFT:
		if not map.check_midLevel(pos + Vector2(-1, 0)):
			if map.check_pos(pos + Vector2(-1, 0)):
				map.move_enemy(pos, pos + Vector2(-1, 0))
				self.position = main.map2screen(pos + Vector2(-1, 0))
	elif dir == BACK_LEFT:
		if not map.check_midLevel(pos + Vector2(-1, -1)):
			if map.check_pos(pos + Vector2(-1, -1)):
				map.move_enemy(pos, pos + Vector2(-1, -1))
				self.position = main.map2screen(pos + Vector2(-1, -1))
	elif dir == BACK:
		if not map.check_midLevel(pos + Vector2(0, -1)):
			if map.check_pos(pos + Vector2(0, -1)):
				map.move_enemy(pos, pos + Vector2(0, -1))
				self.position = main.map2screen(pos + Vector2(0, -1))
	elif dir == BACK_RIGHT:
		if not map.check_midLevel(pos + Vector2(1, -1)):
			if map.check_pos(pos + Vector2(1, -1)):
				map.move_enemy(pos, pos + Vector2(1, -1))
				self.position = main.map2screen(pos + Vector2(1, -1))
	elif dir == RIGHT:
		if not map.check_midLevel(pos + Vector2(1, 0)):
			if map.check_pos(pos + Vector2(1, 0)):
				map.move_enemy(pos, pos + Vector2(1, 0))
				self.position = main.map2screen(pos + Vector2(1, 0))
	elif dir == FRONT_RIGHT:
		if not map.check_midLevel(pos + Vector2(1, 1)):
			if map.check_pos(pos + Vector2(1, 1)):
				map.move_enemy(pos, pos + Vector2(1, 1))
				self.position = main.map2screen(pos + Vector2(1, 1))
