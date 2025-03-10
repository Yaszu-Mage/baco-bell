extends Control
@onready var health = $PanelContainer/VBoxContainer/GridContainer/Health
@onready var mana = $PanelContainer/VBoxContainer/GridContainer/Mana
@onready var portrait = $PanelContainer/VBoxContainer/TextureRect
var islocal = false

func _process(delta: float) -> void:
	if islocal:
		scale = Vector2(1,1)
	else:
		scale = Vector2(0.5,0.5)
