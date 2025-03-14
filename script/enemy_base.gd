extends Node3D
enum Named {THING_1, THING_2, ANOTHER_THING = -1}
enum spawn_reason {
	Natural,
	Spawned,
}
enum spawn_location {
	the_void
}
var id = randi_range(0,1024)
var type = 0
var enemy_type = ""
var spawn_location_value = spawn_location.the_void;
var reason = spawn_reason.Natural;
var me
@onready var multiplayer_sync = $MultiplayerSynchronizer
func _ready() -> void:
	print(multiplayer_sync.replication_config)
	match type:
		0:
			enemy_type = "cuber"
			me = load("res://scenes/cuber.tscn").instantiate()
			add_child(me)


func _on_visible_on_screen_enabler_3d_screen_entered() -> void:
	me.visible = true


func _on_visible_on_screen_enabler_3d_screen_exited() -> void:
	me.visible = false
