extends Area3D
var mouse_in = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and mouse_in:
		get_parent().get_parent().clicked = self

func _on_mouse_entered() -> void:
	mouse_in = true


func _on_mouse_exited() -> void:
	mouse_in = false
