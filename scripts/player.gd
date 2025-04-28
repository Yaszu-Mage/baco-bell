extends Node2D

@onready var player = $player
var username
var old_user = ""
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if old_user != username:
		old_user = username
		player.username = old_user




func fling(direction):
	player.fling(direction)
