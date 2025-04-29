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
@onready var rigid_body = $"../RigidBody2D"
enum StateMode {
	Dashing,
	Walking,
	Crouching,
	Running,
	Aiming,
	Idle,
	Falling,
	Jumping,
	WallClimbing,
	Grappeling,
	Swapping,
	Attacking
}
var State = StateMode.Walking
var old_state = State
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
		if State != StateMode.Aiming:
			$grappel_throw.visible = false
		if State == StateMode.Grappeling:
			sprite.play("swinging")
			self.global_position = rigid_body.global_position
			line.visible = true
			line.clear_points()
			line.add_point(self.global_position)
			line.add_point((((self.global_position + grappel_point.global_position) / 2) + (Vector2(rigid_body.linear_velocity.x,0) / 8)))
			line.add_point(grappel_point.global_position)
			
			rpc("sync_line",line.points)
			if Input.is_action_just_pressed("ui_accept"):
				State = StateMode.Falling
				line.clear_points()
				rpc("sync_line",line.points)
		elif State == StateMode.Swapping:
			print("swapping")
			
		elif State != StateMode.Grappeling and State != StateMode.Swapping:
			line.visible = false
			line.clear_points()
			rpc("sync_line",line.points)
			rigid_body.global_position = self.global_position
		
		# Add the gravity.
		if not is_on_floor() and (!is_on_wall_slide) and !dashing and !is_on_wall_slide and $Node2D/CPUParticles2D.emitting == false and !bouncing and !cheatmode and State != StateMode.Grappeling:
			velocity += get_gravity() * delta
			sprite.play("fall")
			State = StateMode.Falling
		elif is_on_wall_slide and !(Input.is_action_pressed("dash") or Input.is_action_pressed("slide") or Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down")):
			if Input.is_action_pressed("ui_left"):
				sprite.flip_h = true
			else:
				sprite.flip_h = false
			sprite.play("wall")
			velocity.y = (get_gravity().y - Vector2(0,780).y) * delta
			State = StateMode.WallClimbing
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
		if grappel_points != [] and State != StateMode.Grappeling:
			grappel_points.sort_custom(sort_distance)
			for x in grappel_points:
				x.farthest()
			grappel_points[0].closest()
			pinpoint.global_position = grappel_points[0].global_position
			grappel_point.global_position = grappel_points[0].global_position
			pinpoint.top_level = true
			pinpoint.length = clamp(pinpoint.global_position.distance_to(self.global_position),0,20)
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction := Input.get_axis("ui_left", "ui_right")
		var direction_y = Input.get_axis("ui_up","ui_down")
		if State == StateMode.Aiming:
			grapple_throw.rotate(direction / 10)
			grapple_throw.rotation_degrees = clampf(grapple_throw.rotation_degrees,-90,90)
		if direction and State == StateMode.Grappeling:
			rigid_body.linear_velocity.x += direction * 10
		if is_on_floor() and direction:
			sprite.flip_v = false
			if State == StateMode.Walking:
				match direction:
					1.0:
						sprite.flip_h = false
						sprite.play("walk")
					-1.0:
						sprite.flip_h = true
						sprite.play("walk")
		elif !direction and is_on_floor() and (!Input.is_anything_pressed() or (Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down")) and State == StateMode.Idle):
			sprite.play("idle")
		if cheatmode:
			var fly_dir = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
			if fly_dir:
				velocity = fly_dir * SPEED
			else:
				velocity = Vector2.ZERO
		else:
			if direction and is_on_floor() and !dashing and State != StateMode.Aiming and State != StateMode.Grappeling:
				velocity.x = direction * SPEED
				if State != StateMode.Aiming:
					State = StateMode.Walking
			elif direction and !is_on_floor() and !dashing and State != StateMode.Grappeling:
				State = StateMode.Falling
				velocity.x = direction * (SPEED / 1.2)
			elif direction and is_on_floor() and State == StateMode.Aiming:
				velocity.x = direction * (SPEED / 10)
			elif !dashing and !direction and State != StateMode.Grappeling and !bouncing and !is_on_wall_slide:
				if State != StateMode.Aiming and State != StateMode.Grappeling:
			
					State = StateMode.Idle
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
			State = StateMode.WallClimbing
			is_on_wall_slide = true
		else:
			is_on_wall_slide = false
		rpc("remote_sync",self.global_position,$AnimatedSprite2D.animation,$AnimatedSprite2D.flip_v,$AnimatedSprite2D.flip_h)
		move_and_slide()
	
func	 reset_state():
	pass
func dash(direction,direction_y):
	if dashing:
		State = StateMode.Dashing
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

@rpc("unreliable")
func sync_line(values : PackedVector2Array):
	line.points = values

func _on_cansee_exit(body: Node2D) -> void:
	if body == $".":
		$Camera2D.global_position.y = self.global_position.y


func _on_butt_area_exited(area: Area2D) -> void:
	if area == $Camera2D/cansee:
		$Camera2D.global_position.y = self.global_position.y


func fling(direction : Vector2):
	if bouncing:
		State = StateMode.Falling
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
@onready var line = $grappel
@onready var pinpoint = $"../PinJoint2D"
@onready var grapple_throw = $grappel_throw
@onready var grappel_point = $"../grappel_point"
var hooked = false
var is_aiming = false
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left"):
		sprite.flip_h = true
	else:
		sprite.flip_h = false
	if event.is_action_pressed("grappel"):
		if grappel_points != []:
			if grappel_points[0].global_position.distance_to(self.global_position) >= 500:
				print(grappel_points[0].global_position.distance_to(self.global_position))
			else:
				State = StateMode.Swapping
				grapple_throw.visible = false
				rigid_body.global_position = self.global_position
				State = StateMode.Grappeling
	if event.is_action_pressed("toggle_grappel_throw"):
		if State == StateMode.Aiming:
			var cast = grapple_throw.cast.is_colliding()
			var output = cast [0]
			var collider = cast[1]
			if output:
				State = StateMode.Swapping
				grapple_throw.visible = false
				pinpoint.global_position = collider.global_position
				grappel_point.global_position = collider.global_position
				pinpoint.top_level = true
				pinpoint.length = clamp(pinpoint.global_position.distance_to(self.global_position),0,20)
				await get_tree().create_timer(0.1).timeout
				for x in 20:
					rigid_body.global_position = self.global_position
				State = StateMode.Grappeling
				
		else:
			grapple_throw.visible = true
			State = StateMode.Aiming
			grapple_throw.rotation = 0

func spawn_tp():
	self.global_position = spawn
	$Camera2D.global_position.y = self.global_position.y

@rpc("unreliable")
func remote_sync(authority_pos,authority_animation,flipv,fliph):
	self.global_position = authority_pos
	$AnimatedSprite2D.animation = authority_animation
	$AnimatedSprite2D.play(authority_animation)
	$AnimatedSprite2D.flip_h = fliph
	$AnimatedSprite2D.flip_v = flipv
	
var grappel_points = []

func remove_point(who: Node):
	grappel_points.remove_at(grappel_points.find(who))
	grappel_points.sort_custom(sort_distance)
	if grappel_points != []:
		grappel_points[0].closest()
func fit(who : Node):
	grappel_points.append(who)
	grappel_points.sort_custom(sort_distance)
	grappel_points[0].closest()
	for point in grappel_points:
		point.farthest()
	grappel_points[0].closest()
	
func sort_distance(a : Node, b : Node):
	return a.global_position.distance_to(self.global_position) < b.global_position.distance_to(self.global_position)
