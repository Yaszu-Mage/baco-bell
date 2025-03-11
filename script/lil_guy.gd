extends Node3D
@onready var animation = $AnimationPlayer
func play_animation(animation_str):
	animation.play(animation_str)
