extends Area3D

var bod
func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		bod = body
		$Sprite3D.visible = true

func _process(delta: float) -> void:
	if bod and Input.is_action_just_pressed("interact"):
		bod.is_in_building = true
		bod.global_position = $"../../../buildinginside1".global_position


func _on_body_exited(body: Node3D) -> void:
	if body == bod:
		$Sprite3D.visible = false
		bod = null


func _input(event: InputEvent) -> void:
	if bod and event.is_action_pressed("interact"):
		print("interact")
		bod.is_in_building = true
		bod.global_position = $"../../../buildinginside1".global_position
