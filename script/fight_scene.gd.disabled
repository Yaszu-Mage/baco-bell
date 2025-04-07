extends Node3D

#Will be a list of all fighters regardless of side
var fighters : Array
#Will be a list of all fighters WITH initiative
#Stored as [LINK,Value] 
var initiative : Array
enum world_types {
  the_void
}
var world : world_types
var is_local
@export var turn = 0
@export var jumped = 0
@onready var resources : ResourcePreloader = get_parent().resources
func _ready() -> void:
  print("Fight Scene Ready Started")
  if !is_local:
	self.visible = false
	jumped = randi_range(0,3)
	rpc("authority_jumped",jumped)
  match world:
	world_types.the_void:
	  var instance = resources.get_resource("void_town").instantiate()
	  instance.position = Vector3(0,-2,5.782)
	  add_child(instance)
  await get_tree().create_timer(0.2).timeout
  if jumped > 0:
	for amount in jumped:
	  var instance = resources.get_resource("enemy").instantiate()
	  get_parent().add_child(instance,true)
	  await get_tree().create_timer(0.01).timeout
	  var actual_enemy = instance.get_main()
	  print("enemy" + str(amount + 1))
	  actual_enemy.can_move = false
	  actual_enemy.local_fight = true
	  actual_enemy.global_position = get_node("enemy" + str(amount + 2)).global_position
	  actual_enemy.fight_instance = self
	  fighters.append(str(instance.name))
  
