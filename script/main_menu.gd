extends Control
var multiplayer_peer = ENetMultiplayerPeer.new()

const PORT = 9999
const ADDRESS = "127.0.0.1"
@export var username_sync = {}
@onready var server_list := $menu2/multi2/server_list
@onready var item = preload("res://assets/images/crazy.png")
var client_discovery := preload("res://addons/lan_server_discovery/client_discovery.gd").new()
var server_discovery := preload("res://addons/lan_server_discovery/server_discovery.gd").new()
var connected_peer_ids = []
var local_player_character
@export var instances = {}
var world = preload("res://scenes/world.tscn")
var selected_button = 0
@onready var menu_2_anim = $menu2/AnimationPlayer
@onready var anim = $anim
var menu = false
# starting at zero 
func _ready() -> void:
	anim.play("start")
	add_child(client_discovery)
	# Connect signal when a server is found
	client_discovery.server_found.connect(_on_server_found)
	# Optionally clear server list at start
	server_list.clear()


func _input(event: InputEvent) -> void:
	if menu == false and event is InputEventJoypadButton or event is InputEventKey:
		menu = true
		anim.play("flash")
		await get_tree().create_timer(0.12).timeout
		anim.play("show_buttons")


func _on_server_found(server_ip):
	print("server found! at " + server_ip)
	server_list.add_item(server_ip,item)
	print(server_list.get_item_text(0))
	print(server_list.item_count)
	print(server_list.get_item_icon(0))


func add_player_character(peer_id):
	connected_peer_ids.append(peer_id)
	var username = $menu2/multi2/username.text
	if username != "":
		username_sync.set(connected_peer_ids[0],username)
		print(username_sync.get(connected_peer_ids[0]))
	var player_character = preload("res://scenes/player.tscn").instantiate()
	instances.set(connected_peer_ids[0],player_character)
	player_character.set_multiplayer_authority(peer_id)
	get_parent().get_node("world").add_child(player_character)
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
	if !$AnimationPlayer.is_playing():
		$AnimationPlayer.play("bop")


func _on_solo_pressed() -> void:
	pass # Replace with function body.


func _on_multi_pressed() -> void:
	pass # Replace with function body.



func _on_host_pressed() -> void:
	$WorldEnvironment.queue_free()
	$DirectionalLight3D.queue_free()
	$Camera2D.queue_free()
	$SubViewport.queue_free()
	var world_instance = world.instantiate()
	get_parent().add_child(world_instance,true)
	multiplayer_peer.close()
	#Instead of using show() hide()
	#Nodename.property = value
	$".".visible = false
	multiplayer_peer.create_server(PORT)
	multiplayer.multiplayer_peer = multiplayer_peer
	add_child(server_discovery)
	server_discovery.start_listening()
	add_player_character(1)
	multiplayer_peer.peer_connected.connect(
		func(new_peer_id):
			await get_tree().create_timer(1).timeout
			rpc("add_newly_connected_player_character", new_peer_id)
			rpc_id(new_peer_id, "add_previously_connected_player_characters", connected_peer_ids)
			add_player_character(new_peer_id)
	)


func _on_join_pressed() -> void:
	$WorldEnvironment.queue_free()
	$DirectionalLight3D.queue_free()
	$Camera2D.queue_free()
	$SubViewport.queue_free()
	print("joining local")
	$".".visible = false
	var world_instance = world.instantiate()
	get_parent().add_child(world_instance,true)
	var ip = ""
	if $menu2/multi2/multi/VBoxContainer/HBoxContainer2/ip.text == "":
		ip = "localhost"
	else:
		ip = $menu2/multi2/multi/VBoxContainer/HBoxContainer2/ip.text
	multiplayer_peer.create_client(ip, PORT)
	multiplayer.multiplayer_peer = multiplayer_peer
	await get_tree().create_timer(1.0).timeout
	if is_instance_valid(get_node("world2")):
		get_node("world2").queue_free()


func _on_scan_pressed() -> void:
	server_list.clear()
	client_discovery.reset_discovered_servers()
	client_discovery.broadcast_request()


func _on_server_list_item_selected(index: int) -> void:
	var server_ip = server_list.get_item_text(index)
	print("Connecting to:", server_ip)
	$WorldEnvironment.queue_free()
	$DirectionalLight3D.queue_free()
	$Camera2D.queue_free()
	$SubViewport.queue_free()
	$".".visible = false
	var world_instance = world.instantiate()
	get_parent().add_child(world_instance,true)
	
	multiplayer_peer.create_client(server_ip, PORT)
	multiplayer.multiplayer_peer = multiplayer_peer


func _on_delve_pressed() -> void:
	# old - pro multiplayer menu_2_anim.play("show_multi")
	$WorldEnvironment.queue_free()
	$DirectionalLight3D.queue_free()
	$Camera2D.queue_free()
	$SubViewport.queue_free()
	var world_instance = world.instantiate()
	get_parent().add_child(world_instance,true)
	multiplayer_peer.close()
	#Instead of using show() hide()
	#Nodename.property = value
	$".".visible = false
	multiplayer_peer.create_server(PORT)
	multiplayer.multiplayer_peer = multiplayer_peer
	add_child(server_discovery)
	server_discovery.start_listening()
	add_player_character(1)
	multiplayer_peer.peer_connected.connect(
		func(new_peer_id):
			await get_tree().create_timer(1).timeout
			rpc("add_newly_connected_player_character", new_peer_id)
			rpc_id(new_peer_id, "add_previously_connected_player_characters", connected_peer_ids)
			add_player_character(new_peer_id)
	)
