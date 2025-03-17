# addons/lan_server_discovery/client_discovery.gd

extends Node
class_name ClientDiscovery

var udp_broadcaster := PacketPeerUDP.new()
var udp_listener := PacketPeerUDP.new()
const DISCOVERY_PORT := 4242
const BROADCAST_IP := "255.255.255.255"
const REQUEST_MESSAGE := "LookingForServer"
const RESPONSE_MESSAGE := "GameServerHere"

signal server_found(server_ip: String)

var discovered_servers: Array = []
 
func _ready() -> void:
	start_discovery()
func broadcast_request():
	udp_broadcaster.close()
	udp_broadcaster.bind(4242)
	udp_broadcaster.set_broadcast_enabled(true)
	udp_broadcaster.set_dest_address(BROADCAST_IP, DISCOVERY_PORT)
	udp_broadcaster.put_packet(REQUEST_MESSAGE.to_utf8_buffer())
	
	print("ClientDiscovery: Broadcasted discovery request.")

var CLIENT_PORT = 5000  # Choose an unused port

func start_discovery():
	udp_listener.close()
	var result = udp_listener.bind(CLIENT_PORT)
	if result != OK:
		push_error("Failed to bind client UDP socket!")
	udp_listener.set_broadcast_enabled(true)


func reset_discovered_servers():
	discovered_servers.clear()

func _process(_delta):
	
	if udp_listener.get_available_packet_count() > 0:
		print("we got something in the listener")
		var sender_ip = udp_listener.get_packet_ip()
		var data = udp_listener.get_packet().get_string_from_utf8()
		if data == RESPONSE_MESSAGE and sender_ip not in discovered_servers:
			print("server found!")
			discovered_servers.append(sender_ip)
			emit_signal("server_found", sender_ip)
			print("ClientDiscovery: Found server at %s" % sender_ip)
