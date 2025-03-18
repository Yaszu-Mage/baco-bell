extends Node3D
@onready var E = $Sprite3D
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		E.visible = true
	if body.is_multiplayer_authority():
		if Input.is_action_just_pressed("interact"):
			pass


func _on_area_3d_body_exited(body: Node3D) -> void:
	if E.visible:
		E.visible = not E.visible
