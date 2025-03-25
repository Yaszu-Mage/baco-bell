extends Node3D

var combatants = {
	"Players" : {

	},
	"Enemies": {

	}
}

@export var players = []
@export var enemies = []
var not_local = false
#World Type for Generation
enum world_type {
	the_void
}
var world
#"Instance name"
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
func _ready() -> void:
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
			get_parent().add_child(instance,true)
			await get_tree().create_timer(0.01).timeout
			var actual_enemy = instance.get_main()
			print("enemy" + str(amount + 1))
			actual_enemy.can_move = false
			actual_enemy.local_fight = true
			actual_enemy.global_position = get_node("enemy" + str(amount + 2)).global_position
			actual_enemy.fight_instance = self
			combatants_list.append(str(instance.name))
	await get_tree().create_timer(0.5).timeout
	print("combatants list is now: " + str(combatants_list))
	if not_local:
		pass
	else:
		for entity in combatants_list:
			var initial = entity
			entity = get_parent().get_node(initial)
			if entity.is_in_group("player"):
				#Run player things
				combatants.get("Players").set(entity.username,entity)
				var initiative_roll = randi_range(0,20)
				intiative.append([entity,initiative_roll])
				players.append(initial)
				entity.can_move = false
				entity.turnbased_menu.visible = true
			if entity.is_in_group("enemies"):
				#Run enemies things
				combatants.get("Enemies").set(entity.enemy_type,entity)
				enemies.append(str(initial))
				var initiative_roll = randi_range(0,20)
				intiative.append([initial,initiative_roll])
				entity.can_move = false
		print("intiative order has been decidied!" + str(intiative))
		rpc("sync_variables",intiative,combatants_list,combatants)
		run_turn()

func run_turn():
	print(intiative)
	if !not_local:
		for entries in intiative:
			var entity = get_parent().get_node(entries[0])
			entity.turn()
			await action_chose
			print("passed!")
			if is_instance_valid(entity):
				if entity.is_in_group("player"):
					entity.reset_actions()
					entity.rpc("reset_actions_remote")
					await get_tree().create_timer(0.1).timeout
				if entity.is_in_group("player"):
					entity.not_turn()
			for entry in intiative:
				var entity2 = get_parent().get_node(entry[0])
				entity2.turn()
				if is_instance_valid(entity2):
					if entity2.health <= 0:
						entity2.death()
			if enemies == []:
				for play in players:
					var player = get_parent().get_node(play)
					player.death()


@rpc("any_peer")
func sync_variables(init,combat,combats):
	intiative = init
	combatants_list = combat
	combatants = combats


func run_action(entity,action,target = null, _type = ""):
	var initial = entity
	if !not_local:
		entity = get_parent().get_node(initial)
		match action:
			"Count_Up":
				if entity.is_in_group("player"):
					entity.display_message(str(entity.username + " has attempted Count Up and..."))
				var coin_flip = randi_range(0,1)
				if coin_flip == 1:
					if entity.is_in_group("player"):
						if entity.effects.has("Strength"):
							entity.effects.set("Strength",entity.effects.get("Strength")+1)
						else:
							entity.effects.set("Strength",1)
