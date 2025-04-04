extends Node2D
var not_local = false
enum world_type {
	the_void
}
var world = world_type.the_void
@onready var view = $world
#idea for storage, [player_name,type,turn based scene name]
var left_fighters = [["Yaszu","player"]]
var right_fighters = [["cuber","enemy"]]
var all_fighters = []
var initiative = []

signal move_on
#local player will be index
var localplayer = 0
# Called when the node enters the scene tree for the first time.
#new max is 3 on each side
@onready var line_left_instances = [$Left_Marks/Left,$Left_Marks/Left2,$Left_Marks/Left3]
@onready var line_right_instances = [$Right_Marks/Right,$Right_Marks/Right2,$Right_Marks/Right3]
func _ready() -> void:
	print("ready started!")
	if not_local:
		self.visible = false
	else:
		match world:
			world_type.the_void:
				var instance = GlobalLists.load.get_resource("void_town").instantiate()
				instance.position = Vector3(0,-2,5.782)
				view.add_child(instance)
	for fighters in left_fighters:
		var entity_name = fighters[0]
		var entity_type = fighters[1]
		var instance
		match entity_type:
			"player":
				instance = load("res://scenes/fight_prototype/player.tscn").instantiate()
				instance.side_tag = "left"
				instance.side = left_fighters
			"enemy":
				match entity_name:
					"cuber":
						instance = load("res://scenes/fight_prototype/enemy.tscn").instantiate()
						instance.type = entity_name
						instance.side = left_fighters
						instance.side_tag = "left"
		instance.position_in_line = left_fighters.find(fighters)
		instance.name = entity_name
		add_child(instance)
		all_fighters.append(fighters)
	for fighters in right_fighters:
		var entity_name = fighters[0]
		var entity_type = fighters[1]
		var instance
		match entity_type:
			"player":
				instance = load("res://scenes/fight_prototype/player.tscn").instantiate()
				instance.side_tag = "right"
				instance.side = right_fighters
			"enemy":
				match entity_name:
					"cuber":
						instance = load("res://scenes/fight_prototype/enemy.tscn").instantiate()
						instance.type = entity_name
						instance.side = right_fighters
						instance.side_tag = "right"
		instance.position_in_line = right_fighters.find(fighters)
		instance.name = entity_name
		add_child(instance)
		all_fighters.append(fighters)
	for entry in all_fighters:
		var initiative_roll = randi_range(0,20)
		initiative.append([entry,initiative_roll])
		print(entry[0]," rolled a ",initiative_roll)
	initiative.sort_custom(sort_ascending)
	print("Initiative order has been decided! ", initiative)
	if !not_local:
		rpc("sync_variables",initiative,all_fighters,left_fighters,right_fighters)
	await get_tree().create_timer(0.1).timeout
	turn_cycle()
	
@rpc("call_remote")
func sync_variables(init,all,left,right):
	print("syncing variables")
	initiative = init
	all_fighters = all
	left_fighters = left
	right_fighters = right

func turn_cycle():
	for turn in initiative:
		var taker = get_node(turn[0][0])
		var fighter_entry = turn[0]
		if fighter_entry[1] == "player":
			print("Player's Turn")
			taker.turn()
			await move_on

func sort_ascending(a, b):
	if a[1] > b[1]:
		return true
	return false
	




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#TODO recode this

func run_action(entity_name, action, target_name = null, _type = ""):
	var entity = get_node(entity_name)
	if not_local:
		entity = get_parent().get_node(entity_name)
	
	match action:
		"Count_Up":
			if entity.side_tag == "left":
				entity.display_message(str(entity.name + " has attempted Count Up and..."))
			var coin_flip = randi_range(0, 1)
			if coin_flip == 1:
				if entity.side_tag == "left":
					if entity.effects.has("Strength"):
						entity.effects["Strength"] += 1
					else:
						entity.effects["Strength"] = 1
			else:
				for entry in initiative:
					var local_entity = get_node(entry[0][0])
					if local_entity.side_tag == "left":
						local_entity.display_message(str(entity.name + " landed tails."))
				if entity.effects.has("Weakness"):
					entity.effects["Weakness"] += 1
				else:
					entity.effects["Weakness"] = 1

		"Pass":
			pass

		"Punch":
			var target = get_node(target_name[0])
			if entity.side_tag == "left":
				entity.display_message(entity.name + " has punched " + target.name)
			if entity.side_tag == "right":
				target.take_attack(2, target_name, [0, 2, 4])
			if entity.side_tag == "left":
				target.damage(4)
			#now we play the actual animation
			entity.animate("Punch", target.position)

		"Rush_Hour":
			if entity.side_tag == "left":
				entity.health += randi_range(0, 5)

		"Minimum_Effort":
			if entity.side_tag == "left":
				entity.health += 4

		"Company_Investment":
			var target = get_node(target_name)
			if entity.side_tag == "left":
				entity.display_message(entity.name + " has invested into " + target.name)
				target.damage(1)

		"Aftermath":
			var target = get_node(target_name)
			if entity.side_tag == "left":
				entity.display_message(entity.name + " has force-fed " + target.name + " bacos. " + target.name + " is now constipated!")
				target.effects.append("Constipated")

		"Fake_Identity":
			entity.effects.clear()
