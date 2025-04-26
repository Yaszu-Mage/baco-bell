extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_left_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if !body.bouncing:
			body.bouncing = true
			body.bounce_timer.start()
			body.fling(Vector2(-1, -0.2))
			$left/zap.visible = true
			await get_tree().create_timer(0.5).timeout
			$left/zap.visible = false


func _on_right_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if !body.bouncing:
			body.bouncing = true
			body.bounce_timer.start()
			body.fling(Vector2(1, -0.2))
			$right/zap.visible = true
			await get_tree().create_timer(0.5).timeout
			$right/zap.visible = false


func _on_center_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if !body.bouncing:
			body.bouncing = true
			body.bounce_timer.start()
			body.fling(Vector2(0,1))
			$center/zap.visible = true
			await get_tree().create_timer(0.5).timeout
			$center/zap.visible = false
