extends Panel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var itemlist
var pockets

# which pocket are we displaying currently?
var display_mode = "botannicals"

var botannicals = {"apple": 1, "dandelion": 2, "fern": 3}
var materials = {"stick": 5, "rock": 5}
var weapons = {"sword": 1}

var global

# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false
	itemlist = self.get_node("ItemList")
	pockets = self.get_node("pockets")
	global = get_node("/root/global")
	
	pockets.add_item("botannicals")
	pockets.add_item("materials")
	pockets.add_item("weapons")
	
	reset_itemlist()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func new_item(item):
	itemlist.add_item(item.type)

func reset_itemlist():
	itemlist.clear()
	
	var d = get_pocket()
	
	for i in d.keys():
		itemlist.add_item(i)
	

func get_pocket():
	if display_mode == "botannicals":
		return botannicals
	elif display_mode == "materials":
		return materials
	elif display_mode == "weapons":
		return weapons

func has_bot(t):
	if botannicals.has(t):
		return true
	else:
		return false



func on_opened():
	self.visible = true
	itemlist.grab_focus()

func _on_close_pressed():
	self.visible = false
	self.get_parent().get_parent().mode = "overworld"

func _on_ItemList_item_activated(index):
	var d = get_pocket()
	var name = itemlist.get_item_text(index)
	
	self.get_node("info/num_items").text = "In bag: " + str(d[itemlist.get_item_text(index)])
	self.get_node("info/item_name").text = name
	
	var i
	
	if display_mode == "botannicals":
		i = global.botannical
	elif display_mode == "materials":
		i = global.material
	elif display_mode == "weapons":
		i = global.weapon
	
	self.get_node("info/flavor_text").text = i[name].flavor_text
	self.get_node("info/effects").text = i[name].effect
	self.get_node("info/item").texture = load(i[name].large_sprite)
	



func _on_pockets_item_activated(index):
	display_mode = pockets.get_item_text(index)
	reset_itemlist()
	
