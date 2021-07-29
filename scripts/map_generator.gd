extends Node2D

const NORTH = 0
const SOUTH = 1
const EAST = 2
const WEST = 3
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var map


var params
## example feature dict
#var feat = {
#	"type": "corridor_NS",
#	"topleft": Vector2(4, 3),
#	"bottomright": Vector2(4, 7)
#	}


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	map = self.get_node("TileMap")
	generate_map(Vector2(80, 60), 4, 3, 6)


# generate map of size sz
# connectivity c
# mindim minD
# maxdim maxD
func generate_map(sz, c, minD, maxD):
	var p = {
		"mapsize": sz,
		"connectivity": c,
		"minDim": minD,
		"maxDim": maxD
		}
		
	params = p
	
	for x in range(sz.x):
		for y in range(sz.y):
			map.set_cellv(Vector2(x, y), 1)
	
	# generate first feature: a room set randomly in the available space
	var x_sz = (randi()%(maxD-minD)) + minD
	var y_sz = (randi()%(maxD-minD)) + minD
	print(str(x_sz) + " " + str(y_sz))
	
	
	# this is the position of the top left corner
	var x_pos = (randi()%(int(sz.x - x_sz)))
	var y_pos = (randi()%(int(sz.y - y_sz)))
	print(str(x_pos) + " " + str(y_pos))
	
	
	var feat = {
		"type": "room",
		"topleft": Vector2(x_pos, y_pos),
		"bottomright": Vector2(x_pos + x_sz, y_pos + y_sz)
	}
	
	print(feat)
	
	draw_feature(feat)
	
	propagate(feat, p)
	
	

# feat is feature
# params is dict of sz, c, minD, maxD
func propagate(feat, params):
	# repeat to the degree of connectivity
	for i in range(params["connectivity"]):
		yield(get_tree().create_timer(1.0), "timeout")
		
		# pick a wall
		var face
		
		var newFeat = {
			"type":"none",
			"topleft": Vector2(0, 0),
			"bottomright":Vector2(0, 0)
			}
		
		if feat["type"] == "room":
			# we can build on any of the 4 faces
			face = randi()%4
			
			# 90% chance corridor, 10% chance room
			var t = randi()%10
			
			if t == 0: # make it a room
				newFeat["type"] = "room"
				
				var size = Vector2(((randi()%(params["maxDim"]-params["minDim"])) + params["minDim"]), ((randi()%(params["maxDim"]-params["minDim"])) + params["minDim"]))
				
				#place it on the side of the old feature
				if face == NORTH:
					var top = feat["topleft"].y - 1 - size.y
					var bottom = feat["topleft"].y - 1
					
					var left = randi()%(int(feat["bottomright"].x - (feat["topleft"].x - size.x + 1))) + feat["topleft"].x - size.x + 1
					var right = left + size.x
					
					newFeat["topleft"] = Vector2(left, top)
					newFeat["bottomright"] = Vector2(right, bottom)
				elif face == SOUTH:
					var top = feat["bottomright"].y + 1
					var bottom = feat["bottomright"].y + 1 + size.y
					
					var left = randi()%(int(feat["bottomright"].x - (feat["topleft"].x - size.x + 1))) + feat["topleft"].x - size.x + 1
					var right = left + size.x
					
					newFeat["topleft"] = Vector2(left, top)
					newFeat["bottomright"] = Vector2(right, bottom)
				elif face == EAST:
					var top = randi()%(int(feat["bottomright"].y - (feat["topleft"].y - size.y + 1))) + feat["topleft"].y - size.y + 1
					var bottom = top + size.y
					
					var left = feat["bottomright"].x + 1
					var right = left + size.x
					
					newFeat["topleft"] = Vector2(left, top)
					newFeat["bottomright"] = Vector2(right, bottom)
				elif face == WEST:
					var top = randi()%(int(feat["bottomright"].y - (feat["topleft"].y - size.y + 1))) + feat["topleft"].y - size.y + 1
					var bottom = top + size.y
					
					var right = feat["topleft"].x - 1
					var left = right - size.x
					
					newFeat["topleft"] = Vector2(left, top)
					newFeat["bottomright"] = Vector2(right, bottom)
				
				
				
			else: # make new feat a corridor
				if face == NORTH or face == SOUTH:
					newFeat["type"] = "corridor_NS"
					
					var length = randi()%(params["maxDim"]-params["minDim"]) + params["minDim"]
					
					var left = randi()%(int(feat["bottomright"].x - feat["topleft"].x)) + feat["topleft"].x
					
					if face == NORTH:
						var top = feat["topleft"].y-1-length
						var bottom = feat["topleft"].y - 1
						
						newFeat["topleft"] = Vector2(left, top)
						newFeat["bottomright"] = Vector2(left, bottom)
						
					elif face == SOUTH:
						var top = feat["bottomright"].y-1
						var bottom = feat["bottomright"].y-1-length
						
						newFeat["topleft"] = Vector2(left, top)
						newFeat["bottomright"] = Vector2(left, bottom)
					
					
				else:
					newFeat["type"] = "corridor_EW"
					
					var length = randi()%(params["maxDim"]-params["minDim"]) + params["minDim"]
					
					var top = randi()%(int(feat["bottomright"].y-feat["topleft"].y)) + feat["topleft"].y
					
					if face == EAST:
						var left = feat["bottomright"].x + 1
						var right = feat["bottomright"].x + 1 + length
						
						newFeat["topleft"] = Vector2(left, top)
						newFeat["bottomright"] = Vector2(right, top)
					elif face == WEST:
						var left = feat["topleft"].x - 1 - length
						var right = feat["topleft"].x - 1
						
						newFeat["topleft"] = Vector2(left, top)
						newFeat["bottomright"] = Vector2(right, top)
				
			
			
		elif feat["type"] == "corridor_NS":
			face = randi()%4
			
			if face == NORTH:
				
				# let's say that there's a 75% chance of a room ending a corridor
				# otherwise, it's another corridor
				if randi()%4 == 1: # corridor, can be NS or EW (but more likely EW
					var length = randi()%(params["maxDim"]-params["minDim"]) + params["minDim"]
					
					if randi()%4 == 1:
						newFeat["type"] = "corridor_NS"
						newFeat["topleft"] = Vector2(feat.x, feat.y - 1 - length)
						newFeat["bottomright"] = Vector2(feat.x, feat.y - 1)
					else:
						newFeat["type"] = "corridor_EW"
						
						var left = feat["topleft"].x - randi()%(length)
						
						newFeat["topleft"] = Vector2(left, feat["topleft"].y - 1)
						newFeat["bottomright"] = Vector2(left + length, feat["topleft"].y - 1)
					
					
				else: # room
					newFeat["type"] = "room"
					
					var size = Vector2(((randi()%(params["maxDim"]-params["minDim"])) + params["minDim"]), ((randi()%(params["maxDim"]-params["minDim"])) + params["minDim"]))
					
					var left = feat["topleft"].x - randi()%int(size.x)
					var right = left + size.x
					
					var bottom = feat["topleft"].y - 1
					var top = bottom - size.y
					
					newFeat["topleft"] = Vector2(left, top)
					newFeat["bottomright"] = Vector2(right, bottom)
				
				
			elif face == SOUTH:
				# let's say that there's a 75% chance of a room ending a corridor
				# otherwise, it's another corridor
				if randi()%4 == 1: # corridor, can be NS or EW (but more likely EW
					var length = randi()%(params["maxDim"]-params["minDim"]) + params["minDim"]
					
					if randi()%4 == 1:
						newFeat["type"] = "corridor_NS"
						newFeat["topleft"] = Vector2(feat.x, feat.y + 1)
						newFeat["bottomright"] = Vector2(feat.x, feat.y + 1 + length)
					else:
						newFeat["type"] = "corridor_EW"
						
						var left = feat["topleft"].x - randi()%(length)
						
						newFeat["topleft"] = Vector2(left, feat["topleft"].y + 1)
						newFeat["bottomright"] = Vector2(left + length, feat["topleft"].y + 1 + length)
					
					
				else: # room
					newFeat["type"] = "room"
					
					var size = Vector2(((randi()%(params["maxDim"]-params["minDim"])) + params["minDim"]), ((randi()%(params["maxDim"]-params["minDim"])) + params["minDim"]))
					
					var left = feat["topleft"].x - randi()%int(size.x)
					var right = left + size.x
					
					var bottom = feat["topleft"].y + 1 + size.y
					var top = feat["topleft"].y + 1 
					
					newFeat["topleft"] = Vector2(left, top)
					newFeat["bottomright"] = Vector2(right, bottom)
			elif face == EAST:
				pass
				
				#EW corridor is the only option
				#newFeat["type"] = "corridor_EW"
				#var length = randi()%(params["maxDim"]-params["minDim"]) + params["minDim"]
				
				#var top = randi()%int(feat["bottomright"].y - feat["topleft"].y) + feat["topleft"].y
				
				#newFeat["topleft"] = Vector2(feat["topleft"].x + 1, top)
				#newFeat["bottomright"] = Vector2(feat["topleft"].x + 1 + length, top)
				
			elif face == WEST:
				pass
				
				#EW corridor is the only option
				#newFeat["type"] = "corridor_EW"
				#var length = randi()%(params["maxDim"]-params["minDim"]) + params["minDim"]
				
				#var top = randi()%int(feat["bottomright"].y - feat["topleft"].y) + feat["topleft"].y
				
				#newFeat["topleft"] = Vector2(feat["topleft"].x - 1 - length, top)
				#newFeat["bottomright"] = Vector2(feat["topleft"].x -1, top)
			
		elif feat["type"] == "corridor_EW":
			pass
		
		# now we have a new feature described
		# we need to check that it will fit into the described space
		# TODO: we could, to increase connectivity, allow a small percentage of overlaps
		# to still be drawn. tbd
		if check_overlap(newFeat):
			print("feature accepted!")
			print(newFeat)
			draw_feature(newFeat)
			propagate(newFeat, params)


# checks the area feat will occupy,
# returns true if it is all wall
# returns false if there are already features in it
func check_overlap(feat):
	if feat["topleft"].x < 0 or feat["topleft"].y < 0 or feat["bottomright"].x >= params["mapsize"].x or feat["bottomright"].y >= params["mapsize"].y:
		return false
	
	
	for x in range(feat["topleft"].x, feat["bottomright"].x + 1):
		for y in range(feat["topleft"].y, feat["bottomright"].y + 1):
			if map.get_cellv(Vector2(x, y)) == 0:
				return false
	return true

#draws the given feature to the map
func draw_feature(feat):
	for x in range(feat["topleft"].x, feat["bottomright"].x + 1):
		for y in range(feat["topleft"].y, feat["bottomright"].y + 1):
			map.set_cellv(Vector2(x, y), 0)
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
