extends Control
var multiplayer_peer = ENetMultiplayerPeer.new()

const PORT = 9999
const ADDRESS = "127.0.0.1"
@export var username_sync = {}
@onready var server_list := $Menu/GridContainer/ItemList
@onready var item = preload("res://assets/images/crazy.png")
var client_discovery := preload("res://addons/lan_server_discovery/client_discovery.gd").new()
var server_discovery := preload("res://addons/lan_server_discovery/server_discovery.gd").new()
var connected_peer_ids = []
var local_player_character
@export var instances = {}
var world = preload("res://scenes/world.tscn")
var selected_button = 0
@onready var buttons = [$Delve]
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
