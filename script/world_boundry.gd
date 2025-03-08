extends Area3D



func _on_body_entered(body: Node3D) -> void:
	body.global_position = Vector3(0,100,0)
