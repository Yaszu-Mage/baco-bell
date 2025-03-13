extends CharacterBody3D

var health = 100
const SPEED = 5.0
const JUMP_VELOCITY = 22.5
var can_wall_jump = true
@onready var list = $"Menu/List of Players"
var is_sliding = false
var slide_speed = 2.0
var slide_stamina = 100
var slide_duration = 10
@onready var little_guy = $lil_guy_rig
var request
@export var username = ""
@onready var menu = $Menu
var accepted = false
var party_marker : Node = null
var wall_limit = 3
var is_wall_running = false
var slide_exponent = 0.1
var can_double_jump = true
var rotating_now = false
@export var party = []
var is_in_party = false
var last_raw_dir : Vector3
@onready var cam_rot = $cam_pivot/SpringArm3D
@onready var _camera_pivot = $cam_pivot
var wall_normal
@onready var camera = $cam_pivot/SpringArm3D/Camera3D
@onready var floor_ray = $RayCast3D
var fall = Vector3() 
var waller = false
var clicked = false
var last_direction : Vector3 = Vector3.ZERO
enum world_type {
	the_void
}
@onready var title_card = $ColorRect/TextureRect
@onready var fade = $ColorRect
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	wall_min_slide_angle = 90
	name = str(get_multiplayer_authority())
	var tween = create_tween()
	if is_multiplayer_authority():
		fade.visible = true
		tween.tween_property(fade,"color",Color(0,0,0,0),1)
		await get_tree().create_timer(0.5).timeout
		var world = get_parent().get_node("world")
		var world_enum = world.world
		match world_enum:
			world_type.the_void:
				var new_tween = create_tween()
				title_card.texture = load("res://assets/images/void_titlecard.png")
				new_tween.tween_property(title_card,"modulate",Color(1,1,1,1),1)
				await get_tree().create_timer(2.0).timeout
				var brand_new_tween = create_tween()
				brand_new_tween.tween_property(title_card,"modulate",Color(1,1,1,0),1)

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		$Sprite3D.visible = true
		camera.current = true
		# Add the gravity.
		
		if is_on_floor():
			can_wall_jump = true
			can_double_jump = true
			wall_limit = 3
		# Get the input direction and handle the movement/deceleration.
			# As good practice, you should replace UI actions with custom gameplay actions	.
		var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		
		var forward = camera.global_basis.z
		var right = camera.global_basis.x
		var move_direction = forward * input_dir.y + right * input_dir.x
		if is_on_wall_only() and Input.is_action_pressed("ui_accept") and !floor_ray.is_colliding() and !Input.is_action_pressed("slide") and wall_limit > 0:
			var tween = create_tween()
			tween.tween_property(camera,"fov",90,1)
			wall_normal = get_slide_collision(0)
			if wall_normal.get_normal().x != 0:
				if wall_normal.get_normal().x > 0:
					move_direction.z = -move_direction.z * -wall_normal.get_normal().x * (SPEED)
				if wall_normal.get_normal().x < 0:
					move_direction.z = move_direction.z * -wall_normal.get_normal().x * (SPEED)
			if wall_normal.get_normal().z != 0:
				if wall_normal.get_normal().z > 0:
					move_direction.x = -move_direction.x * -wall_normal.get_normal().z * (SPEED)
				if wall_normal.get_normal().x < 0:
					move_direction.x = move_direction.x * -wall_normal.get_normal().z * (SPEED)
			await get_tree().create_timer(0.2).timeout
			is_wall_running = true
		elif Input.is_action_just_released("ui_accept") and is_wall_running and is_on_wall():
			wall_normal = get_slide_collision(0)
			if wall_normal.get_normal().x != 0:
				for x in 100:
					move_direction.x = -wall_normal.get_normal().x * JUMP_VELOCITY
					velocity.y = JUMP_VELOCITY
			if wall_normal.get_normal().z != 0:
				for x in 100:
					move_direction.z = -wall_normal.get_normal().z * JUMP_VELOCITY
					velocity.y = JUMP_VELOCITY
			wall_limit -= 1
		else:
			is_wall_running = false
			if (camera.fov == 90):
				var tween = create_tween()
				tween.tween_property(camera,"fov",75,1)
		if !is_on_wall():
			is_wall_running = false
		if Input.is_action_pressed("slide"):
			var tween = create_tween()
			tween.tween_property(camera,"fov",95,0.1)
			if slide_exponent < 0:
				velocity = last_raw_dir * pow(2,1 / slide_exponent) * SPEED * 2
				slide_exponent += 0.5
				move_and_slide()
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
				velocity.z = move_toward(velocity.z, 0, SPEED)
		else:
			slide_exponent = -10.0
			if camera.fov == 95:
				var tween = create_tween()
				tween.tween_property(camera,"fov",75,0.1)
		if is_on_floor() and direction:
			little_guy.play_animation("Walking")
			rpc("sync_anim","Walking")
			$GPUParticles3D.emitting = true
		elif is_on_floor() and !input_dir:
			little_guy.play_animation("Idle")
			rpc("sync_anim","Idle")
			$GPUParticles3D.emitting = false
		var target_angle = Vector3.BACK.signed_angle_to(last_raw_dir,Vector3.UP)
		move_direction = move_direction.normalized()
		if direction and !menu.visible:
			velocity = velocity.move_toward(move_direction * SPEED,delta * 20)
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
		if move_direction.length() > 0.2:
			last_raw_dir = move_direction
		little_guy.global_rotation.y = target_angle
				# Handle jump.
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		if Input.is_action_just_pressed("ui_accept") and !is_on_wall() and !is_on_floor() and can_double_jump:
			velocity.y = JUMP_VELOCITY
			little_guy.play_animation("Flip")
			rpc("sync_anim","Flip")
			can_double_jump = false
		if not is_on_floor() and !is_wall_running:
			velocity += get_gravity() * delta * 5
		move_and_slide()
		rpc("remote_set_position", velocity,global_position,little_guy.rotation)


@rpc("unreliable")
func remote_set_position(authority_velocity,authority_position,authority_rot):
	velocity = authority_velocity
	global_position = authority_position
	little_guy.rotation = authority_rot
	move_and_slide()


@rpc("unreliable")
func remote_set_username(authority_name):
	username = authority_name
func _input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		if Input.is_action_just_pressed("menu"):
			menu.visible = not menu.visible
			if !menu.visible:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			else:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			if list.visible:
				list.visible = not list.visible
			

func _process(delta: float) -> void:
	if is_multiplayer_authority():
		_camera_pivot.global_position = self.global_position
		rpc("remote_set_username",username)
		username = GlobalLists.username
		var listpos = GlobalLists.usernames.get(name)
		if listpos != username:
			GlobalLists.usernames.set(name,username)
	if is_in_party and party_marker == null:
		var instance = load("res://scenes/player_party.tscn").instantiate()
		for c in $VBoxContainer.get_children():
			$VBoxContainer.remove_child(c)
		$VBoxContainer.add_child(instance)
		instance.islocal = true
	if $"Menu/List of Players".visible:
		$"Menu/List of Players/GridContainer/ItemList".clear()
		var parent = get_parent()
		for n in parent.get_children():
			if n.is_in_group("player"):
				$"Menu/List of Players/GridContainer/ItemList".add_item(n.username)
		


func _on_party_pressed() -> void:
	$"Menu/List of Players".visible = not $"Menu/List of Players".visible

@rpc("any_peer")
func send_request(id,target):
	if username != id and target == username and is_multiplayer_authority():
		$Notification/VBoxContainer/RichTextLabel.text = id + " has invited you to their party!"
		request = id
		$AnimationPlayer.play("notification_on")
		await get_tree().create_timer(30).timeout
		$AnimationPlayer.play_backwards("notification_on")
func _on_item_list_item_selected(index: int) -> void:
	var list = $"Menu/List of Players/GridContainer/ItemList"
	var user = list.get_item_text(index)
	var parent = get_parent()
	var player = null
	for n in parent.get_children():
		if n.is_in_group("player"):
			if n.username == user:
				player = n
				print(n.username)
	if player != null:
		print(username,player.username)
		
		player.get_request(username,player.username)
	await get_tree().create_timer(30.0).timeout
	if accepted:
		is_in_party = true
		party.append(player)
func get_request(use,playuse):
	rpc("send_request",use,playuse)

func _on_quit_pressed() -> void:
	get_tree().quit(0)


func _on_button_pressed() -> void:
	var parent = get_parent()
	for n in parent.get_children():
		if n.is_in_group("player"):
			if n.username == request:
				n.rpc("accept")
				party = n.party

@rpc("any_peer")
func accept():
	accepted = true
@rpc("unreliable")
func sync_anim(anim):
	little_guy.play_animation(anim)
@export_range(0.0, 1.0) var mouse_sensitivity = 0.01
@export var tilt_limit = deg_to_rad(75)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and is_multiplayer_authority():
		_camera_pivot.rotation.x -= event.relative.y * mouse_sensitivity
		# Prevent the camera from rotating too far up or down.
		_camera_pivot.rotation.x = clampf(_camera_pivot.rotation.x, -tilt_limit, tilt_limit)
		_camera_pivot.rotation.y += -event.relative.x * mouse_sensitivity
