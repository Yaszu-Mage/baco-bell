extends Node3D
@onready var E = $Sprite3D
var bod
var fight = []
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and body.is_multiplayer_authority():
		E.visible = true
		bod = body


func _on_area_3d_body_exited(body: Node3D) -> void:
	if E.visible:
		E.visible = not E.visible
	if bod:
		bod = null


#button name is interact
func _process(delta):
	#Use the Input Class
	#blah.join_fight(fight)
	if Input.is_action_just_pressed("interact") and bod != null:
		bod.join_fight(fight)



	
	
	
