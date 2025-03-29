extends Node3D

#when a body in the group of player or item or enemy is standing on it, it changes pressed boolean variable to true
var pressed = false
var current_presser = null
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") or body.is_in_group("enemies") or body.is_in_group("item"):
		pressed = true 
		current_presser = body

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.is_in_group("player") or area.is_in_group("enemies") or area.is_in_group("item"):
		pressed = true
		current_presser = area

#check if current presser is body if so make current presser null
func _on_area_3d_area_exited(area: Area3D) -> void:
	if area.is_in_group("player") or area.is_in_group("enemies") or area.is_in_group("item"):
		pressed = false
		current_presser = null

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player") or body.is_in_group("enemies") or body.is_in_group("item"):
		pressed = false
		current_presser = null
