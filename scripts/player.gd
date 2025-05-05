extends Node2D

@onready var player = $player
var username = ""
var old_user = ""
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if old_user != username:
		old_user = username
		player.username = old_user
	for child in get_children():
		if child.is_in_group("player"):
			player = child
	name = player.name + " " + str(get_multiplayer_authority())
	rpc("set_name_authority",name)


@rpc("any_peer")
func set_name_authority(authority_name):
	name = authority_name


func fling(direction):
	player.fling(direction)
