extends Panel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var itemlist
var pockets

# which pocket are we displaying currently?
var display_mode = "botannicals"

var botannicals = {"apple": 1, "marigold": 2, "fern": 3}
var materials = {"stick": 5, "rock": 5}
var weapons = {"sword": 1}

# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false
	itemlist = self.get_node("ItemList")
	pockets = self.get_node("pockets")
	
	pockets.add_item("botannicals")
	pockets.add_item("materials")
	pockets.add_item("weapons")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func new_item(item):
	itemlist.add_item(item.type)

func reset_itemlist():
	itemlist.clear()
	
	var d
	if display_mode == "botannicals":
		d = botannicals
	elif display_mode == "materials":
		d = materials
	elif display_mode == "weapons":
		d = weapons
	
	for i in d.keys():
		itemlist.add_item(i)
	


func on_opened():
	self.visible = true
	itemlist.grab_focus()

func _on_close_pressed():
	self.visible = false
	self.get_parent().get_parent().mode = "overworld"
	# TODO: unlock parent controls

func _on_ItemList_item_activated(index):
	print(index)
	print(itemlist.get_item_text(index))
	



func _on_pockets_item_activated(index):
	display_mode = pockets.get_item_text(index)
	reset_itemlist()
	
