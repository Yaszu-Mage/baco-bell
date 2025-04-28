extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func is_colliding():
	var output = false
	var collider = null
	if $middle.is_colliding():
		if $middle.get_collider().is_in_group("grappel_point"):
			collider = $middle.get_collider()
			output = true
	if $left.is_colliding():
		if $left.get_collider().is_in_group("grappel_point"):
			collider = $left.get_collider()
			output = true
	if $right.is_colliding():
		if $right.get_collider().is_in_group("grappel_point"):
			collider = $right.get_collider()
			output = true
	return [output, collider]
