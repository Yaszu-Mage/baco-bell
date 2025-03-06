extends Area3D
var mouse_in = false
@onready var parent = get_parent()
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and mouse_in and parent.can_click:
		get_parent().clicked.emit()
		get_parent().get_parent().get_parent().get_parent().clicked_button.emit()



func _on_mouse_entered() -> void:
	mouse_in = true
	if parent.can_click:
		get_parent().get_parent().get_parent().get_parent().clicked = self


func _on_mouse_exited() -> void:
	mouse_in = false
	if parent.can_click:
		get_parent().get_parent().get_parent().get_parent().clicked = null
