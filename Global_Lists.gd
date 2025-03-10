extends Node
var abilities = {
	"Name":{
		"Type": "type_value", # can be attack, healing, or defend
		"Value": 1, # integer that it changes something by
		"Continuous": false, # if it takes multiple turns
	},
	"Fireball":{
		"Type": "Attack",
		"Value": 7,
		"Continuous": false
	},
}
enum environments {
	the_void,
}
enum ability_types {attack,healing,defend}
var players = []
var usernames = {}
var instances = {}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
