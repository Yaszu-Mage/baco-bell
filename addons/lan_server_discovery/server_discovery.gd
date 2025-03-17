# addons/lan_server_discovery/server_discovery.gd

extends Node
class_name ServerDiscovery

var udp_listener := PacketPeerUDP.new()
const DISCOVERY_PORT := 4242
const RESPONSE_MESSAGE := "GameServerHere"

signal discovery_request_received(sender_ip: String)

func start_listening():
	udp_listener.close()
	var result = udp_listener.bind(DISCOVERY_PORT)
	udp_listener.set_broadcast_enabled(true)
	if result != OK:
		push_error("Failed to bind UDP socket on port %d" % DISCOVERY_PORT)
	else:
		print("ServerDiscovery: Listening for discovery requests on port %d" % DISCOVERY_PORT)

func stop_listening():
	udp_listener.close()
	print("ServerDiscovery: Stopped listening.")

func _process(_delta):
	if udp_listener.get_available_packet_count() > 0:
		print("we found something")
		var sender_ip = udp_listener.get_packet_ip()
		var sender_port = udp_listener.get_packet_port()
		var data = udp_listener.get_packet().get_string_from_utf8()
		if data == "LookingForServer":
			# Respond
			print("we responded to " + sender_ip," " ,sender_port)
			udp_listener.set_dest_address("localhost", 5000)
			udp_listener.put_packet(RESPONSE_MESSAGE.to_utf8_buffer())
			emit_signal("discovery_request_received", sender_ip)
