extends Node3D
var combatants = {
	"Players" : {
},
	"Enemies":{

}
}
#So we are going to store players and enemies in two places and two formats
var players = []
var enemies = []
#World Type for Generation
enum world_type {
	the_void
}
var world
#["Player_Name",Instance]
var combatants_list = []
#[Instance,initiative order]
var intiative = []
signal action_chose
var turn = 0
var preloaded_enemy = preload("res://scenes/enemy_base.tscn")
@onready var camera = $Camera3D
#We will roll initiative like DND so 1-20
#We can roll by using randi_range(1,20)
# We need to store combatants FIRST before we put it into the dictionary
func _ready():
	print("ready started!")
	
	match world:
		world_type.the_void:
			var instance = load("res://scenes/void_town.tscn").instantiate()
			instance.position = Vector3(0,-2,5.782)
			add_child(instance)
	var jumped = randi_range(0,3)
	if jumped > 0:
		for amount in jumped:
			var instance = preloaded_enemy.instantiate()
			add_child(instance)
			await get_tree().create_timer(0.01).timeout
			var actual_enemy = instance.get_main()
			print("enemy" + str(amount + 1))
			actual_enemy.can_move = false
			actual_enemy.global_position = get_node("enemy" + str(amount + 2)).global_position
			actual_enemy.fight_instance = self
			combatants_list.append(actual_enemy)
	await get_tree().create_timer(0.5).timeout
	print("combatants list is now: " + str(combatants_list))
	for entity in combatants_list:
		if entity.is_in_group("player"):
			#Run player things
			combatants.get("Players").set(entity.username,entity)
			var initiative_roll = randi_range(0,20)
			intiative.append([entity,initiative_roll])
			players.append(entity)
			entity.can_move = false
			entity.turnbased_menu.visible = true
		if entity.is_in_group("enemies"):
			#Run enemies things
			combatants.get("Enemies").set(entity.enemy_type,entity)
			enemies.append(entity)
			var initiative_roll = randi_range(0,20)
			intiative.append([entity,initiative_roll])
			entity.can_move = false
	print("intiative order has been decidied!" + str(intiative))
	run_turn()

func run_turn():
	print(intiative)
	for entries in intiative:
		entries[0].turn()
		await action_chose
		print("passed!")
		if is_instance_valid(entries[0]):
			if entries[0].is_in_group("player"):
				entries[0].reset_actions()
				await get_tree().create_timer(0.1).timeout
			if entries[0].is_in_group("player"):
				entries[0].not_turn()
		for entry in intiative:
			if is_instance_valid(entry[0]):
				if entry[0].health <= 0:
					entry[0].death()
		if enemies == []:
			for player in players:
				player.death()
				
	turn += 1
	print("turn finished, we are now on turn " +str(turn))
	run_turn()

func run_action(entity,action,target = null,_type = ""):
	match action:
		"Count_Up":
			for entries in intiative:
				if entries[0].is_in_group("player"):
					entries[0].display_message(str(entity.username + " has attempted Count Up and..."))
			#Flip a coin for buffs
			var coin_flip = randi_range(0,1)
			if coin_flip == 1:
				if entity.is_in_group("player"):
					entity.logger("Heads")
					for entries in intiative:
						if entries[0].is_in_group("player"):
							entries[0].display_message(str(entity.username + " landed heads!"))
				if entity.effects.has("Strength"):
					entity.effects.set("Strength",entity.effects.get("Strength")+1)
				else:
					entity.effects.set("Strength",1)
			else:
				for entires in intiative:
					if entires[0].is_in_group("player"):
						entires[0].display_message(str(entity.username + " landed tails."))
				entity.logger("Tails")
				if entity.effects.has("Weakness"):
					entity.effects.set("Weakness",entity.effects.get("Weakness")+1)
				else:
					entity.effects.set("Weakness",1)
		"Pass":
			pass
		"Punch":
			for entries in intiative:
				if entries[0].is_in_group("player"):
					entries[0].display_message(str(entity.username + " has punched " + target.username))
			if entity.is_in_group("enemies"):
				target.damage(2)
			if entity.is_in_group("player"):
				target.damage(4)
	await get_tree().create_timer(0.2).timeout
	action_chose.emit()

@rpc("any_peer")
func sync_action(player,action):
	pass

func _process(delta):
	find_invalid()
func get_combatants(source):
	if source.is_in_group("player"):
		return combatants.get("Enemies")
	elif source.is_in_group("enemies"):
		return combatants.get("Players")

func end_fight():
	for entry in enemies:
		entry.can_move = true
	self.queue_free()

func kill_me(ref):
	print(str(intiative) + " is start")
	var index = 0
	for entry in intiative:
		index += 1
		if entry[0] == ref:
			intiative.remove_at(index)
	print(index)
	intiative.remove_at(index)
	index = 0
	for entry in intiative:
		index += 1
		if entry[0] == ref:
			intiative.remove_at(index)
	intiative.remove_at(index)
	print(str(intiative) + " should be right")
	combatants_list.remove_at(combatants_list.find(Node))

func find_invalid():
	await get_tree().create_timer(0.1).timeout
	for entries in intiative:
		if is_instance_valid(entries[0]):
			pass
		else:
			print("We have pruned instance at" + str(entries))
			intiative.remove_at(intiative.find(entries))
