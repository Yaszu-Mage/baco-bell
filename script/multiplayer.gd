extends Node3D
var multiplayer_peer = ENetMultiplayerPeer.new()

const PORT = 9999
const ADDRESS = "127.0.0.1"
@export var username_sync = {}
var connected_peer_ids = []
var local_player_character
@export var instances = {}
var world = preload("res://scenes/world.tscn")
func _on_host_pressed():
	var world_instance = world.instantiate()
	add_child(world_instance)
	$Menu.visible = false
	multiplayer_peer.create_server(PORT)
	multiplayer.multiplayer_peer = multiplayer_peer
	add_player_character(1)
	multiplayer_peer.peer_connected.connect(
		func(new_peer_id):
			await get_tree().create_timer(1).timeout
			rpc("add_newly_connected_player_character", new_peer_id)
			rpc_id(new_peer_id, "add_previously_connected_player_characters", connected_peer_ids)
			add_player_character(new_peer_id)
	)


func _on_join_pressed():
	$Menu.visible = false
	var world_instance = world.instantiate()
	add_child(world_instance)
	multiplayer_peer.create_client("localhost", PORT)
	multiplayer.multiplayer_peer = multiplayer_peer

func add_player_character(peer_id):
	connected_peer_ids.append(peer_id)
	var username = $Menu/GridContainer/TextEdit.text
	if username != "":
		username_sync.set(connected_peer_ids[0],username)
		print(username_sync.get(connected_peer_ids[0]))
	var player_character = preload("res://scenes/player.tscn").instantiate()
	instances.set(connected_peer_ids[0],player_character)
	player_character.set_multiplayer_authority(peer_id)
	add_child(player_character)
	if player_character.is_multiplayer_authority():
		player_character.username = username
	GlobalLists.username = username
	if peer_id == multiplayer.get_unique_id():
		local_player_character = player_character

@rpc	
func add_newly_connected_player_character(new_peer_id):
	add_player_character(new_peer_id)
	
@rpc
func add_previously_connected_player_characters(peer_ids):
	for peer_id in peer_ids:
		add_player_character(peer_id)

func _process(delta: float) -> void:
	GlobalLists.players = connected_peer_ids
	GlobalLists.usernames = username_sync
	GlobalLists.instances = instances
