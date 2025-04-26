extends CharacterBody2D

## MOVEMENT VARIABLES ie CHANGE THIS TO CHANGE MOVEMENT INFO##
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var jumps = 2
const dash_time = 0.1
var spawn : Vector2

var movement_direction = Vector2.ZERO
@onready var bounce_timer = $bounce_timer
var username = ""
@onready var dash_timer = $dash_timer
@onready var sprite = $AnimatedSprite2D
var dashing = false
var can_dash = true
var cheatmode = false
var bouncing = false
var is_on_wall_slide = false
enum StateMode {
	Dashing,
	Walking,
	Crouching,
	Running
}
var State = StateMode.Walking
var can_time = true
func _ready() -> void:
	name = str(get_multiplayer_authority())
	$Camera2D.global_position.y = self.global_position.y
	spawn = Vector2(502,545)
	if is_multiplayer_authority():
		$Camera2D.enabled = true
func _physics_process(delta: float) -> void:
	#Keep camera x
	if is_multiplayer_authority():
		$Camera2D.global_position.x = self.global_position.x
		$Node2D.global_position = self.global_position
		# Add the gravity.
		if not is_on_floor() and (!is_on_wall_slide) and !dashing and !is_on_wall_slide and $Node2D/CPUParticles2D.emitting == false and !bouncing and !cheatmode:
			velocity += get_gravity() * delta
			sprite.play("fall")
		elif is_on_wall_slide and !(Input.is_action_pressed("dash") or Input.is_action_pressed("slide") or Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down")):
			if Input.is_action_pressed("ui_left"):
				sprite.flip_h = true
			else:
				sprite.flip_h = false
			sprite.play("wall")
			velocity = Vector2.ZERO
			velocity = (get_gravity() - Vector2(0,780)) * delta
		if Input.is_action_just_pressed("cheat"):
			cheatmode = not cheatmode
		if is_on_floor():
			jumps = 2
			can_dash = true
		
		# Handle jump.
		if Input.is_action_just_pressed("ui_accept") and (is_on_floor() or jumps > 0):
			velocity.y = JUMP_VELOCITY
			sprite.play("jump")
			jumps -= 1
		
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction := Input.get_axis("ui_left", "ui_right")
		var direction_y = Input.get_axis("ui_up","ui_down")
		if is_on_floor() and direction:
			sprite.flip_v = false
			match direction:
				1.0:
					sprite.flip_h = false
					sprite.play("walk")
				-1.0:
					sprite.flip_h = true
					sprite.play("walk")
		elif !direction and is_on_floor() and (!Input.is_anything_pressed() or (Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down"))):
			sprite.play("idle")
		if cheatmode:
			var fly_dir = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
			if fly_dir:
				velocity = fly_dir * SPEED
			else:
				velocity = Vector2.ZERO
		else:
			if direction and is_on_floor() and !dashing:
				velocity.x = direction * SPEED
			elif direction and !is_on_floor() and !dashing:
				velocity.x = direction * (SPEED / 1.2)
			elif !dashing and !direction:
				velocity.x = move_toward(velocity.x, 0, SPEED)
		movement_direction = Vector2(direction,direction_y)
		if Input.is_action_just_pressed("dash") and can_dash and !is_on_floor():
			dash_timer.wait_time = dash_time
			dash_timer.start()
			dashing = true
			var tween = create_tween()
			dash(direction,direction_y)
			tween.tween_property($Camera2D,"zoom",Vector2(1.9,1.9),0.1)
			await get_tree().create_timer(0.05).timeout
			tween = create_tween()
			tween.tween_property($Camera2D,"zoom",Vector2(2,2),0.5)
			$Node2D/CPUParticles2D.emitting = true
			can_dash = false
		if Input.is_action_just_pressed("slide"):
			if !is_on_floor():
				velocity = Vector2(0,1) * SPEED * 10
			else:
				pass
		if is_on_wall_only() and ((Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right")) and !(Input.is_action_pressed("dash") or Input.is_action_pressed("slide") or Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down"))):
			is_on_wall_slide = true
		else:
			is_on_wall_slide = false
		rpc("remote_sync",self.global_position,$AnimatedSprite2D.animation,$AnimatedSprite2D.flip_v,$AnimatedSprite2D.flip_h)
		move_and_slide()
	
func	 reset_state():
	pass
func dash(direction,direction_y):
	if dashing:
		
		var direction_vector = Vector2(direction,direction_y)
		match Vector2.ZERO.direction_to(direction_vector):
			Vector2(-1.0,0):
				sprite.flip_v = false
				sprite.flip_h = true
				sprite.play("dash_side")
			Vector2(1.0,0):
				sprite.flip_v = false
				sprite.flip_h = false
				sprite.play("dash_side")
			Vector2(0.707107, -0.707107):
				sprite.flip_v = false
				sprite.flip_h = false
				sprite.play("dash_side")
			Vector2(-0.707107, -0.707107):
				sprite.flip_v = false
				sprite.flip_h = true
				sprite.play("dash_side")
			Vector2(0,1.0):
				sprite.flip_v = true
				sprite.flip_h = false
				sprite.play("dash_up")
			Vector2(0,-1.0):
				sprite.flip_v = false
				sprite.flip_h = false
				sprite.play("dash_up")
		$Node2D.rotation = 0
		$Node2D.rotate(Vector2.ZERO.angle_to_point(-direction_vector))
		velocity = Vector2(direction,direction_y) * SPEED * 2
		await get_tree().create_timer(0.1).timeout
		dash(direction,direction_y)
	else:
		await get_tree().create_timer(dash_time * 2).timeout
		sprite.play("fall")
		sprite.flip_v = false
		$Node2D/CPUParticles2D.emitting = false
		return

func on_dash_over() -> void:
	dashing = false



func _on_cansee_exit(body: Node2D) -> void:
	if body == $".":
		$Camera2D.global_position.y = self.global_position.y


func _on_butt_area_exited(area: Area2D) -> void:
	if area == $Camera2D/cansee:
		$Camera2D.global_position.y = self.global_position.y


func fling(direction : Vector2):
	if bouncing:
		if is_on_wall() or is_on_ceiling():
			bouncing = false
		else:
			velocity = direction * SPEED
			move_and_slide()
			await get_tree().create_timer(0.001).timeout
			fling(direction)


func bounce_timeout() -> void:
	bouncing = false


func _on_area_2d_body_entered(body: Node2D) -> void:
	if !body.is_in_group("stage_decorator"):
		bouncing = false

@onready var raycast = $RayCast2D
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("grappel"):
		if raycast.is_colliding():
			var collider = raycast.get_collider()
			if collider.is_in_group("grappel_point"):
				collider.pinpoint.node_b = self

func spawn_tp():
	self.global_position = spawn
	$Camera2D.global_position.y = self.global_position.y

@rpc("unreliable")
func remote_sync(authority_pos,authority_animation,flipv,fliph):
	self.global_position = authority_pos
	$AnimatedSprite2D.animation = authority_animation
	$AnimatedSprite2D.play(authority_animation )
	$AnimatedSprite2D.flip_h = fliph
	$AnimatedSprite2D.flip_v = flipv
	
