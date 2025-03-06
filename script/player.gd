extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var can_wall_jump = true
var is_sliding = false
var slide_speed = 2.0
var slide_stamina = 100
var slide_duration = 10
var wall_limit = 3
var is_wall_running = false
var slide_exponent = 0.1
var can_double_jump = true
var rotating_now = false
@onready var cam_rot = $SpringArm3D
var wall_normal
@onready var floor_ray = $RayCast3D
var fall = Vector3() 
var waller = false
func _ready() -> void:
	wall_min_slide_angle = 90
	name = str(get_multiplayer_authority())

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		$Sprite3D.visible = true
		$SpringArm3D/Camera3D.current = true
		# Add the gravity.
		
		if not is_on_floor() and !is_wall_running:
			velocity += get_gravity() * delta
		if is_on_floor():
			can_wall_jump = true
			can_double_jump = true
			wall_limit = 3
		# Handle jump.
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		if Input.is_action_just_pressed("ui_accept") and !is_on_wall() and !is_on_floor() and can_double_jump:
			velocity.y = JUMP_VELOCITY
			can_double_jump = false
		if Input.is_action_pressed("left"):
			if !rotating_now:
				print("trying to rot")
				rotating_now = true
				var new_value = self.rotation.y + 0.5
				var tween = create_tween()
				tween.tween_property(self,"rotation",Vector3(0,new_value,0),0.1)
				await tween.finished
				rotating_now = false
		if Input.is_action_pressed("right"):
			if !rotating_now:
				print("trying to rot")
				rotating_now = true
				var new_value = self.rotation.y - 0.5
				var tween = create_tween()
				tween.tween_property(self,"rotation",Vector3(0,new_value,0),0.1)
				await tween.finished
				rotating_now = false
		if !Input.is_action_pressed("left") and !Input.is_action_pressed("right"):
			rotating_now = false
		# Get the input direction and handle the movement/deceleration.
			# As good practice, you should replace UI actions with custom gameplay actions	.
		var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if is_on_wall_only() and Input.is_action_pressed("ui_accept") and !floor_ray.is_colliding() and !Input.is_action_pressed("slide") and wall_limit > 0:
			wall_normal = get_slide_collision(0)
			if wall_normal.get_normal().x != 0:
				if wall_normal.get_normal().x > 0:
					direction.z = -direction.z * -wall_normal.get_normal().x * (SPEED)
				if wall_normal.get_normal().x < 0:
					direction.z = direction.z * -wall_normal.get_normal().x * (SPEED)
			if wall_normal.get_normal().z != 0:
				if wall_normal.get_normal().z > 0:
					direction.x = -direction.x * -wall_normal.get_normal().z * (SPEED)
				if wall_normal.get_normal().x < 0:
					direction.x = direction.x * -wall_normal.get_normal().z * (SPEED)
			await get_tree().create_timer(0.2).timeout
			is_wall_running = true
		elif Input.is_action_just_released("ui_accept") and is_wall_running and is_on_wall():
			wall_normal = get_slide_collision(0)
			if wall_normal.get_normal().x != 0:
				for x in 100:
					direction.x = -wall_normal.get_normal().x * JUMP_VELOCITY
					velocity.y = JUMP_VELOCITY
			if wall_normal.get_normal().z != 0:
				for x in 100:
					direction.z = -wall_normal.get_normal().z * JUMP_VELOCITY
					velocity.y = JUMP_VELOCITY
			wall_limit -= 1
		else:
			is_wall_running = false
		if !is_on_wall():
			is_wall_running = false
		if Input.is_action_pressed("slide"):
			if slide_exponent < 0:
				velocity = direction * pow(2,1 / slide_exponent) * SPEED * 2
				slide_exponent += 0.1
				move_and_slide()
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
				velocity.z = move_toward(velocity.z, 0, SPEED)
		else:
			slide_exponent = -10.0
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
		
		rpc("remote_set_position", velocity,global_position)
		move_and_slide()


@rpc("unreliable")
func remote_set_position(authority_velocity,authority_position):
	velocity = authority_velocity
	global_position = authority_position
	move_and_slide()
