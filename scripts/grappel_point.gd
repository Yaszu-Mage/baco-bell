extends StaticBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.is_multiplayer_authority():
		body.fit(self)


func closest():
	$Sprite2D2.visible = true
	
func farthest():
	$Sprite2D2.visible = false


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") and body.is_multiplayer_authority():
		body.remove_point(self)
		$Sprite2D2.visible = false
