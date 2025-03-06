extends MarginContainer
var nameval = "default"
@onready var button = $"../MarginContainer2/VBoxContainer/Button"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_name_val(name_val : String):
	$VBoxContainer/Button.text = name_val
	nameval = name_val


func _on_button_pressed() -> void:
	var parent = get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent()
	var player = get_parent().get_parent().get_parent().get_parent().get_parent()
	
	parent.run_event(player,nameval)
