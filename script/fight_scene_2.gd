extends Node3D
var combatants = {
	"Players" : {
},
	"Enemies":{

}
}
#["Player_Name",Instance]
var combatants_list = []
#[Instance,initiative order]
var intiative = []
signal action_chose
#We will roll initiative like DND so 1-20
#We can roll by using randi_range(1,20)
# We need to store combatants FIRST before we put it into the dictionary
func _ready():
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
			initiative_roll.append([entity,initiative_roll])
			entity.can_move = false

func run_turn():
	for entries in intiative:
		entries[0].turn()
		await action_chose
		entries[0].not_turn()

func run_action(entity,action):
	match action:
		"Count_Up":
			#Flip a coin for buffs
			var coin_flip = randi_range(0,1)
			if coin_flip == 1:
				if entity.is_in_group("player"):
					entity.logger("Heads")
				if entity.effect.has("Strength"):
					entity.effects.set("Strength",entity.effects.get("Strength")+1)
				else:
					entity.effects.set("Strength",1)
			else:
				entity.logger("Tails")
				if entity.effect.has("Weakness"):
					entity.effects.set("Weakness",entity.effects.get("Weakness")+1)
				else:
					entity.effects.set("Weakness",1)
			action_chose.emit()

@rpc("any_peer")
func sync_action(player,action):
	pass
