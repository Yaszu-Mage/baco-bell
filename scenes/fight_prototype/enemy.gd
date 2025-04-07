extends Marker2D
var type = ""
var side = []
var side_tag = ""
var position_in_line
@onready var animation = $AnimationPlayer
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
	fight = get_parent()
	var side_instance
	if side_tag == "left":
		side_instance = fight.get_side("right")
	else:
		side_instance = fight.get_side("left")
	var who = randi_range(0,side_instance.size()- 1 )
	fight.run_action(str(self.name),"Punch",side_instance[who])
	

func animate(attack : String, target_position : Vector2, enemy : String):
	fight = get_parent()
	var enemy_scene = fight.get_node(enemy)
	match attack:
		"Punch":
			var old_pos = global_position
			var tween = create_tween()
			tween.tween_property(self,"global_position",target_position,1)
			await tween.finished
			await get_tree().create_timer(0.1).timeout
			if enemy_scene.is_in_group("player"):
				var time
				if is_in_sprite:
					sprite.play(attack)
					time = sprite.get_current_animation_length()
				else:
					animation.play(attack)
					time = animation.get_current_animation_length()
				enemy_scene.dodge(time, [0,1,2])
				await get_tree().create_timer(time).timeout
				fight.damage_calculated.emit()
			tween = create_tween()
			tween.tween_property(self,"global_position",old_pos,1)

func damage(value : int):
	health -= value
	$RichTextLabel.text = str(value)
	$thing.play("damage")
	$ouch.play()
