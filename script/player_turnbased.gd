extends Node3D
signal go
var can_click = false
var fightbutton = ["Name","Fireball"]
var actbutton = []
var items = []
var flee = []
var targets = []
@onready var grid = $Control/PanelContainer/HBoxContainer/GridContainer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	go.connect(my_turn)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func my_turn():
	can_click = true

func free_mouse():
	if is_multiplayer_authority():
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_fight_pressed() -> void:
	grid.buttons = fightbutton
	grid.add()
