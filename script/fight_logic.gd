extends Node3D
var players = [] ## contains players
var enemies = [] # contains enemies
var combatants = [] # contains all combatants
var initiative = [] # contains all initiative which is name + initiative
var turn = 0
var turnsize
var clicked : Node
signal player_went
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Get players and enemies and roll initiative, whoever rolls highest goes first
	for x in players.size():
		combatants.append(players[x])
	for x in enemies.size():
		combatants.append(enemies[x])
	for x in combatants:
		var init = randi_range(1,20)
		initiative.append([x,init])
	initiative.sort_custom(sort_ascending)
	

func select_enemy():
	pass

func sort_ascending(a, b):
	if a[1] > b[1]:
		return true
	return false
func turns():
	turnsize = initiative.size()
	var goer = initiative[turn]
	if is_player(goer):
		var player = get_node(goer[0])
		player.go.emit()
		await player_went
	
func is_player(turn):
	if players.find(turn[0]):
		return true
	else:
		return false

func increase_turn():
	if turn + 1 > turnsize:
		turn = 0
	else:
		turn += 1

func run_event(player,nameval):
	player.free_mouse()
	while clicked == null:
		pass
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
