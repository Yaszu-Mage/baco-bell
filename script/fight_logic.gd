extends Node3D
var players = ["baller"] ## contains players
var player_instances = [] # contains player INSTANCES 
var enemies = ["ballsack"] # contains enemies
var enemy_instances = [] # contains enemy INSTANCES
var all_intances = []
var combatants = [] # contains all combatants
var initiative = [] # contains all initiative which is name + initiative
var turn = 0
var last_clicked
@onready var enemy_grid = $Control/Enemies
@onready var player_grid = $Control/Players
var environment = GlobalLists.environments.the_void
var turnsize
var world
var clicked : Node
signal clicked_button
signal player_went
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Create environment
	match environment:
		GlobalLists.environments.the_void:
			world = load("res://scenes/world_turnbased.tscn").instantiate()
			add_child(world)
	# Get players and enemies and roll initiative, whoever rolls highest goes first
	for x in players.size():
		combatants.append(players[x])
		var instance = load("res://scenes/player_turnbased.tscn").instantiate()
		instance.name = players[x]
		player_grid.add_child(instance)
		player_instances.append(instance)
		all_intances.append(instance)
		instance.global_position = world.get_node("player_" + str(x + 1)).global_position
	for x in enemies.size():
		combatants.append(enemies[x])
		var instance = load("res://scenes/enemy_turn_base.tscn").instantiate()
		instance.name = enemies[x]
		enemy_grid.add_child(instance)
		enemy_instances.append(instance)
		all_intances.append(instance)
		instance.global_position = world.get_node("enemy_" + str(x + 1)).global_position
	for x in combatants:
		var init = randi_range(1,20)
		initiative.append([x,init])
	initiative.sort_custom(sort_ascending)
	turns()
	



func sort_ascending(a, b):
	if a[1] > b[1]:
		return true
	return false
func turns():
	turnsize = initiative.size()
	var goer = initiative[turn]
	if is_player(goer[0]):
		var player = player_grid.get_node(goer[0])
		player.go.emit()
		await clicked_button
	else:
		var enemy = enemy_grid.get_child(enemy_grid.get_children().find(goer[0]))
		enemy.go.emit()
	await clicked_button
	increase_turn()
	turns()
	
	
func is_player(turn):
	if players.find(turn) >= 1:
		return true
	else:
		return false

func increase_turn():
	turnsize = initiative.size() - 1
	if turn + 1 > turnsize:
		turn = 0
	else:
		turn += 1
	print(turn)

func run_event(player,nameval):
	print(player.name,nameval)
	player.clicked.emit()
	player.can_click = false
	player.ability_selected = false
	
	var used = GlobalLists.abilities.get(nameval)
	print(used)
	var type = used["Type"]
	var value = used["Value"]
	print(type)
	match type:
		"Attack":
			clicked.parent.health -= value
	## TODO Play Animation
	clicked = null
	
	
func get_enemies():
	return enemies

func select_enemy(enemy):
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if clicked != null and last_clicked == clicked:
		var clicker = all_intances[all_intances.find(clicked)]
		
		var mesh : MeshInstance3D = clicker.get_node("Area3D").get_node("mesh").get_node("outline")
		var material = mesh.get_surface_override_material(0)
		material.albedo_color = Color(255,255,0)
		mesh.set_surface_override_material(0,material)
	elif last_clicked != clicked:
		var clicker = all_intances[all_intances.find(clicked)]
		
		var mesh : MeshInstance3D = clicker.get_node("Area3D").get_node("mesh").get_node("outline")
		var material = mesh.get_surface_override_material(0)
		material.albedo_color = Color(0,0,0)
		mesh.set_surface_override_material(0,material)
	last_clicked = clicked
