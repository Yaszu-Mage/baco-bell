extends Node3D
signal go
var can_click = false
var fightbutton = ["Name","Fireball"]
var actbutton = []
var items = []
var flee = []
var targets = []
var ability_selected = false
var health = 100
signal clicked
@onready var grid = $Control/PanelContainer/HBoxContainer/GridContainer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	go.connect(my_turn)
	clicked.connect(toggle)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if ability_selected:
		can_click = true
	$Control/PanelContainer/HBoxContainer/VBoxContainer/VSplitContainer/Buttons/Health.value = health

func my_turn():
	pass
func toggle():
	can_click = false
func free_mouse():
	if is_multiplayer_authority():
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_fight_pressed() -> void:
	grid.buttons = fightbutton
	grid.add()
