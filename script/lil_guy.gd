extends Node3D
@onready var animation = $golem/AnimationPlayer
func play_animation(animation_str):
	animation.play(animation_str)
