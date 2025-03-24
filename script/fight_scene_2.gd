extends Node3D
var combatants = {
	"Players" : {
},
	"Enemies":{

}
}
#So we are going to store players and enemies in two places and two formats
@export var players = []
@export var enemies = []
#Enemy Parent
@export var enemies_mommys = []
var not_local = false
#World Type for Generation
enum world_type {
	the_void
}
var world
#["Player_Name",Instance]
var combatants_list = []
#[Instance,initiative order]
@export var intiative = []
@onready var spawner = $MultiplayerSpawner
signal action_chose
@export var turn = 0
@export var jumped = 0
var preloaded_enemy = preload("res://scenes/enemy_base.tscn")
@onready var camera = $Camera3D
#We will roll initiative like DND so 1-20
#We can roll by using randi_range(1,20)
# We need to store combatants FIRST before we put it into the dictionary
func _ready():
	print("ready started!")
	if not_local:
		pass
	else:
		match world:
			world_type.the_void:
				var instance = load("res://scenes/void_town.tscn").instantiate()
				instance.position = Vector3(0,-2,5.782)
				add_child(instance)
	if not_local:
		self.visible = false
	else:
		jumped = randi_range(0,3)
		rpc("authority_jumped",jumped)
	await get_tree().create_timer(0.2).timeout
	if jumped > 0:
		print(jumped)
		for amount in jumped:
			
			var instance = preloaded_enemy.instantiate()
			add_child(instance,true)
			await get_tree().create_timer(0.01).timeout
			var actual_enemy = instance.get_main()
			print("enemy" + str(amount + 1))
			actual_enemy.can_move = false
			actual_enemy.local_fight = true
			actual_enemy.global_position = get_node("enemy" + str(amount + 2)).global_position
			actual_enemy.fight_instance = self
			combatants_list.append(actual_enemy)
	await get_tree().create_timer(0.5).timeout
	print("combatants list is now: " + str(combatants_list))
	if not_local:
		pass
	else:
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
				enemies.append(str(entity.name))
				enemies_mommys.append(str(entity.get_parent().name))
				var initiative_roll = randi_range(0,20)
				intiative.append([entity,initiative_roll])
				entity.can_move = false
		print("intiative order has been decidied!" + str(intiative))
		rpc("sync_variables",intiative,combatants_list,combatants)
		run_turn()

func run_turn():
	print(intiative)
	if !not_local:
		for entries in intiative:
			entries[0].turn()
			await action_chose
			print("passed!")
			if is_instance_valid(entries[0]):
				if entries[0].is_in_group("player"):
					entries[0].reset_actions()
					entries[0].rpc("reset_actions_remote")
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

@rpc("any_peer")
func authority_jumped(jump):
	jumped = jump

func run_action(entity,action,target = null,_type = ""):
	if !not_local:
		if entity is String:
			var initial = entity
			get_node(entity)
			if entity == null:
				get_parent().get_node(initial)
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
				var enemy = target
				if target is Object:
					pass
				else:
					enemy = get_node(target)
					if enemy == null:
						enemy = get_parent().get_node("world").get_node(target).get_main()
				for entries in intiative:
					if enemy.name.contains("enemy_base"):
							enemy = enemy.get_main()
					if entries[0].is_in_group("player"):
						entries[0].display_message(entries[0].username + " has punched " + enemy.username)
				if entity.is_in_group("enemies"):
					if target is Object:
						target.damage(2)
					else:
						enemy.damage(2)
				if entity.is_in_group("player"):
					enemy.take_attack(2,target,[0,2,4])
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
	rpc("end_fight_remote")
	for entry in enemies:
		entry = get_node(entry)
		if entry == null:
			get_parent().get_node("world").get_node(entry).get_main()
		entry.can_move = true
	self.queue_free()

@rpc("call_remote")
func end_fight_remote():
	self.queue_free()

func kill_me(ref):
	if !not_local:
		print(str(intiative) + " is start")
		print(ref)
		var enemy = get_node(ref)
		if enemy == null:
			enemy = get_parent().get_node("world").get_node(ref)
		print("enemy ", enemy)
		var index = 0
		for entry in intiative:
			index += 1
			print(entry, enemy)
			if entry[0] == enemy:
				intiative.remove_at(index)
		print(index)
		intiative.remove_at(index)
		index = 0
		for entry in intiative:
			index += 1
			if entry[0] == enemy:
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

@rpc("any_peer")
func join_fight(fight):
	print("Has reached fight scene!")
	if !not_local:
		var player = get_parent().get_node(str(fight[3]))
		print(player.name)
		var initiative_roll = randi_range(0,20)
		intiative.append([player,initiative_roll])
		
		players.append(player)
		player.can_move = false
		player.turnbased_menu.visible = true
		#Why not just players.size()? Because of how the nodes are arranged
		# We want player, player2,player3,player4 so with array sizes
		# players.size() + 1 = [0,1,1,2] etc but we don't have to get none since its declared at start
		print(players.size() + 1)
		print(players)
		player.global_position = get_node("player" + str(players.size() + 1)).global_position
		player.rpc("sync_turn_based_actions",player.global_position,str(name),str(player.name))
		rpc("sync_variables",intiative,combatants_list,combatants)
		for enemy in enemies:
			if enemy is String:
				pass
			else:
				player.rpc("show_enemy",str(enemy.name),str(player.name))
		for play in players:
			player.rpc("show_player",str(player.name),str(play.name))
		print("finished!")


@rpc("any_peer")
func sync_variables(init,combat,combats):
	intiative = init
	combatants_list = combat
	combatants = combats
