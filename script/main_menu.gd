extends Control

var selected_button = 0
@onready var buttons = [$Delve]
@onready var anim = $anim
var menu = false
# starting at zero 
func _ready() -> void:
	anim.play("start")


func _input(event: InputEvent) -> void:
	if menu == false and event is InputEventJoypadButton or event is InputEventKey:
		menu = true
		anim.play("flash")
		await get_tree().create_timer(0.12).timeout
		anim.play("show_buttons")
