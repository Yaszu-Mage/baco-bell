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
			pass

func run_action(player,action):
	pass

@rpc("any_peer")
func sync_action(player,action):
	pass
	#MICAH are you there
	#Yea I apologize
