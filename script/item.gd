extends CharacterBody3D

var item_name
var amount
@onready var sprite = $Sprite3D


func _ready() -> void:
	match item_name:
		"Moke":
			load("res://assets/images/items/moke.png")
		"Milk":
			load("res://assets/images/items/milk.png")
		"Boke":
			load("res://assets/images/items/boke.png")




func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		body.add_item(item_name,amount,self)

@rpc("any_peer")
func kill():
	queue_free()
