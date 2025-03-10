extends CharacterBody3D

var health = 100
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var can_wall_jump = true
var is_sliding = false
var slide_speed = 2.0
var slide_stamina = 100
var slide_duration = 10
@onready var menu = $Menu
var accepted = false
var party_marker : Node = null
var wall_limit = 3
var is_wall_running = false
var slide_exponent = 0.1
var can_double_jump = true
var rotating_now = false
var party = []
var is_in_party = false
@onready var cam_rot = $SpringArm3D
var wall_normal
@onready var camera = $SpringArm3D/Camera3D
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
		if Input.is_action_pressed("left") and !menu.visible:
			if !rotating_now:
				rotating_now = true
				var new_value = self.rotation.y + 0.5
				var tween = create_tween()
				tween.tween_property(self,"rotation",Vector3(0,new_value,0),0.1)
				await tween.finished
				rotating_now = false
		if Input.is_action_pressed("right") and !menu.visible:
			if !rotating_now:
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
			var tween = create_tween()
			tween.tween_property(camera,"fov",90,1)
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
			if (camera.fov == 90):
				var tween = create_tween()
				tween.tween_property(camera,"fov",75,1)
		if !is_on_wall():
			is_wall_running = false
		if Input.is_action_pressed("slide"):
			var tween = create_tween()
			tween.tween_property(camera,"fov",95,0.1)
			if slide_exponent < 0:
				velocity = last_direction * pow(2,1 / slide_exponent) * SPEED * 2
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
		if direction and !menu.visible :
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
			last_direction = direction
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

func _input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		if Input.is_action_just_pressed("menu"):
			menu.visible = not menu.visible

func _process(delta: float) -> void:
	if is_in_party and party_marker == null:
		var instance = load("res://scenes/player_party.tscn").instantiate()
		$VBoxContainer.add_child(instance)
		instance.islocal = true
	if $"Menu/List of Players".visible:
		$"Menu/List of Players/GridContainer/ItemList".clear()
		for e in GlobalLists.players:
			$"Menu/List of Players/GridContainer/ItemList".add_item(GlobalLists.usernames.get(e))
		


func _on_party_pressed() -> void:
	$"Menu/List of Players".visible = not $"Menu/List of Players".visible

func send_request(id):
	pass
func _on_item_list_item_selected(index: int) -> void:
	var list = $"Menu/List of Players/GridContainer/ItemList"
	var user = list.get_item_at_position(index)
	var id = GlobalLists.usernames.find_key(user)
	var player = GlobalLists.instances.get(id)
	player.send_request(GlobalLists.usernames.get(GlobalLists.players[0]))
	await get_tree().create_timer(30.0).timeout
	if accepted:
		party.append(player)


func _on_quit_pressed() -> void:
	get_tree().quit(0)
