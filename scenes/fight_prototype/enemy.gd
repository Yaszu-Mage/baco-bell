extends Marker2D
var type = ""
var side = []
var side_tag = ""
var position_in_line
@onready var sprite = $GPUParticles2D/AnimatedSprite2D
var enemy_side = []
var is_in_sprite = true
var health = 10
var fight = get_parent()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match type:
		"cuber":
			sprite.sprite_frames = load("res://scenes/fight_prototype/sprite_frames/enemy.tres")
			is_in_sprite = false
	fight = get_parent()
	match position_in_line:
		0:
			if side_tag == "left":
				self.global_position = fight.line_left_instances[0].global_position
			if side_tag == "right":
				self.global_position = fight.line_right_instances[0].global_position
		1:
			if side_tag == "left":
				self.global_position = fight.line_left_instances[1].global_position
			if side_tag == "right":
				self.global_position = fight.line_right_instances[1].global_position
		2:
			if side_tag == "left":
				self.global_position = fight.line_left_instances[2].global_position
			if side_tag == "right":
				self.global_position = fight.line_right_instances[2].global_position

		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func turn():
	pass
func damage(value : int):
	health -= value
	$RichTextLabel.text = str(value)
	$thing.play("damage")
	$ouch.play()
