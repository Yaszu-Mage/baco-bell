extends GridContainer
var buttons = []
var button = preload("res://scenes/option_button.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func add():
	var column = int(buttons.size())
	if buttons.size() > 3:
		column = buttons.size() / 3
	columns = column
	for x in self.get_children():
		remove_child(x)
	for x in buttons:
		var instance = button.instantiate()
		instance.set_name_val(x)
		add_child(instance)

func send_action_up():
	pass
