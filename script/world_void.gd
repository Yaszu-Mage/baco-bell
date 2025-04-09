extends Node3D
enum world_types {
	the_void
}
enum spawn_reason {
	Natural,
	Spawned,
}
enum spawn_location {
	the_void
}
@onready var resources = $ResourcePreloader
var world = world_types.the_void
var enemy = preload("res://scenes/enemy_base.tscn")
func _ready() -> void:
	name = "world"
	await get_tree().create_timer(0.2).timeout
	var instance = enemy.instantiate()
	instance.reason = "Natural"
	instance.global_position = Vector3(20,0,0)
	add_child(instance)
	var shade1 = enemy.instantiate()
	shade1.reason = "Natural"
	shade1.global_position = $spawn2.global_position
	var shade2 = enemy.instantiate()
	shade2.reason = "Natural"
	shade2.type = 1
	shade1.type = 1
	shade2.global_position = $spawn3.global_position
	add_child(shade2)
	add_child(shade1)
func _process(delta: float) -> void:
	name = "world"
