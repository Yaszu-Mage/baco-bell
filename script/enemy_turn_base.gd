extends Node3D
signal go
var can_click = false
var fightbutton = ["Fireball"]
var actbutton = []
var items = []
var flee = []
var targets = []
var ability_selected = false
var health = 100
signal clicked
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	go.connect(my_turn)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func my_turn():
	if health > 50:
		var chance = randi_range(0,10)
		if chance > 5:
			get_parent().get_parent()
	get_parent().get_parent().get_parent().next_turn.emit()


func _on_area_3d_mouse_entered() -> void:
	pass # Replace with function body.


func _on_area_3d_mouse_exited() -> void:
	pass # Replace with function body.
