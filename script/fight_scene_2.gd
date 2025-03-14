extends Node3D
var combatants = {
	"Players" : {
},
	"Enemies":{

}
}
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
	print("combatants list is now: " + str(combatants_list))
	for entity in combatants_list:
		if entity.is_in_group("player"):
			#Run player things
			combatants.get("Players").set(entity.username,entity)
			var initiative_roll = randi_range(0,20)
			intiative.append([entity,initiative_roll])
			entity.can_move = false
			entity.turnbased_menu.visible = true
		if entity.is_in_group("enemies"):
			#Run enemies things
			combatants.get("Enemies").set(entity.enemy_type,entity)
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
		if entries[0].is_in_group("player"):
			entries[0].reset_actions()
		await get_tree().create_timer(0.1).timeout
		entries[0].not_turn()
	turn += 1
	print("turn finished, we are now on turn " +str(turn))
	run_turn()

func run_action(entity,action):
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
			action_chose.emit()

@rpc("any_peer")
func sync_action(player,action):
	pass
