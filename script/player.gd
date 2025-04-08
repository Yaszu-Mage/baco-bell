extends CharacterBody3D
var health = 10
var SPEED = 5.0
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
@onready var cam_cam = $SubViewport/Camera3D
var accepted = false
var party_marker : Node = null
var can_move = true
var wall_limit = 3
var is_wall_running = false
var slide_exponent = 0.1
var stamina = 100
var can_double_jump = true
var rotating_now = false
#items will be stored as ["Item_Name", 1 (amount)]
var inventory = []
@export var party = []
var slide_limit = 3
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
var world
var last_direction : Vector3 = Vector3.ZERO
enum world_type {
	the_void
}
var gravity
var initial_gravity
@onready var title_card = $ColorRect/TextureRect
@onready var fade = $ColorRect
#returns void
func _ready() -> void:
	initial_gravity = get_gravity()
	gravity = initial_gravity 
	$turn_based_player.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	name = str(get_multiplayer_authority())
	$ColorRect.visible = false
	var tween = create_tween()
	if is_multiplayer_authority():
		$ColorRect/Camera2D.enabled = true
		$ColorRect.visible = true
		camera.current = true
		fade.visible = true
		if username != "":
			username = name
		tween.tween_property(fade,"color",Color(0,0,0,0),1)
		await get_tree().create_timer(0.5).timeout
		world = get_parent()
		var world_enum = world.world
		match world_enum:
			world_type.the_void:
				var new_tween = create_tween()
				title_card.texture = load("res://assets/images/void_titlecard.png")
				new_tween.tween_property(title_card,"modulate",Color(1,1,1,1),1)
				await get_tree().create_timer(2.0).timeout
				var brand_new_tween = create_tween()
				brand_new_tween.tween_property(title_card,"modulate",Color(1,1,1,0),1)
				$GPUParticles3D2.emitting = true
		$ColorRect/Camera2D.enabled = false
@onready var notification_menu_text = $turn_based_player/notifications/main/sub/VBoxContainer/actualtext
func display_message(message : String):
	notification_menu_text.add_text("
" + message)

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		$Sprite3D.visible = true
		# Add the gravity.
		
		if is_on_floor():
			can_wall_jump = true
			can_double_jump = true
			wall_limit = 3
		if ProjectSettings.get_setting("global/mobile"):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			$UI/Joystick.visible = true
		else:
			$UI/Joystick.visible = false
		# Get the input direction and handle the movement/deceleration.
			# As good practice, you should replace UI actions with custom gameplay actions	.
		var input_dir
		if ProjectSettings.get_setting("global/mobile"):
			input_dir = $UI/Joystick.posVector
		elif ProjectSettings.get_setting("global/controller"):
			input_dir = Vector2(Input.get_joy_axis(0,JOY_AXIS_LEFT_X),Input.get_joy_axis(0,JOY_AXIS_LEFT_Y))
		else:
			input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if Input.is_action_pressed("sprint") and stamina > 0:
			if camera.fov >= 75:
				var tween = create_tween()
				tween.tween_property(camera,"fov",95,1)
			SPEED = 15.0
			stamina -= 0.5
		else:
			SPEED = 5.0
			stamina += 0.1
			if camera.fov != 75:
				var tween = create_tween()
				tween.tween_property(camera,"fov",75,1)
		if Input.is_action_pressed("optifine"):
			if camera.fov <= 75:
				var tween = create_tween()
				tween.tween_property(camera,"fov",10,1)
		else:
			if camera.fov != 75:
				var tween = create_tween()
				tween.tween_property(camera,"fov",75,1)
		var forward = camera.global_basis.z
		var right = camera.global_basis.x
		var move_direction = forward * input_dir.y + right * input_dir.x
		if is_on_wall_only() and Input.is_action_pressed("ui_accept") and !floor_ray.is_colliding() and !Input.is_action_pressed("slide") and wall_limit > 0 and can_move:
			print(move_direction)
			var tween = create_tween()
			tween.tween_property(camera,"fov",90,1)
			wall_normal = get_slide_collision(0)
			if wall_normal.get_normal().x != 0:
				little_guy.play_animation("Climb")
				rpc("sync_anim","Climb")
				if wall_normal.get_normal().x > 0:
					move_direction.z = -move_direction.z * -wall_normal.get_normal().reflect(move_direction).normalized().x * (SPEED)
				if wall_normal.get_normal().x < 0:
					move_direction.z = move_direction.z * -wall_normal.get_normal().reflect(move_direction).normalized().x * (SPEED)
			if wall_normal.get_normal().z != 0:
				little_guy.play_animation("Climb")
				rpc("sync_anim","Climb")
				if wall_normal.get_normal().z > 0:
					move_direction.x = -move_direction.x * -wall_normal.get_normal().reflect(move_direction).normalized().z * (SPEED)
				if wall_normal.get_normal().x < 0:
					move_direction.x = move_direction.x * -wall_normal.get_normal().reflect(move_direction).normalized().z * (SPEED)
			print(move_direction)
			await get_tree().create_timer(0.2).timeout
			is_wall_running = true
		elif Input.is_action_just_released("ui_accept") and is_wall_running and is_on_wall() and can_move:
			wall_normal = get_slide_collision(0)
			move_direction = -wall_normal.get_normal().reflect(move_direction) * JUMP_VELOCITY
			velocity.y = JUMP_VELOCITY
			move_direction = -wall_normal.get_normal().reflect(move_direction) * JUMP_VELOCITY
			velocity.y = JUMP_VELOCITY
			wall_limit -= 1
		else:
			is_wall_running = false
			if (camera.fov == 90):
				var tween = create_tween()
				tween.tween_property(camera,"fov",75,1)
		if !is_on_wall():
			is_wall_running = false
		if Input.is_action_just_pressed("slide") and can_move:
			slide_limit -= 1
		if Input.is_action_pressed("slide") and slide_limit < 0 and can_move:
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
			#Setting "Timer" for Slide Increase :3
			slide_check()
			slide_exponent = -10.0
			if camera.fov == 95:
				var tween = create_tween()
				tween.tween_property(camera,"fov",75,0.1)
		if is_on_floor() and direction:
			little_guy.play_animation("Walking")
			rpc("sync_anim","Walking")
			$GPUParticles3D.emitting = true
		elif is_on_floor() and !input_dir:
			little_guy.play_animation("idle")
			rpc("sync_anim","idle")
			$GPUParticles3D.emitting = false
		var target_angle = Vector3.BACK.signed_angle_to(last_raw_dir,Vector3.UP)
		move_direction = move_direction.normalized()
		if move_direction and !menu.visible and can_move:
			velocity = velocity.move_toward(move_direction * SPEED,delta * 20)
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
		if move_direction.length() > 0.2:
			last_raw_dir = move_direction
		if can_move:
			little_guy.global_rotation.y = target_angle
				# Handle jump.
		if Input.is_action_just_pressed("ui_accept") and is_on_floor() and can_move:
			velocity.y = JUMP_VELOCITY
		if Input.is_action_just_pressed("ui_accept") and !is_on_wall() and !is_on_floor() and can_double_jump and can_move:
			velocity.y = JUMP_VELOCITY
			little_guy.play_animation("Flip")
			rpc("sync_anim","Flip")
			can_double_jump = false
		if not is_on_floor() and !is_wall_running:
			velocity += get_gravity() * delta * 5
		move_and_slide()
		rpc("remote_set_position", velocity,global_position,little_guy.rotation)
var waiting = false

@rpc("unreliable")
func remote_set_position(authority_velocity,authority_position,authority_rot):
	if !waiting:
		velocity = authority_velocity
		global_position = authority_position
		little_guy.rotation = authority_rot
	move_and_slide()


@rpc("any_peer")
func reset_actions_remote():
	list_one.clear()
	list_one.add_item("",buttons.get("fight"))
	list_one.add_item("",buttons.get("act"))
	list_one.add_item("",buttons.get("item"))
	list_one.add_item("",buttons.get("team"))
	list_two.clear()

func slide_check():
	if slide_exponent == -10:
		await get_tree().create_timer(10).timeout
		if slide_exponent == -10:
			slide_limit += 1
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
			if $"Menu/Options Window".visible:
				$"Menu/Options Window".visible = not $"Menu/Options Window".visible
		if Input.is_action_just_pressed("inventory"):
			menu.visible = true
			$Menu/Buttons.visible = false
			$Menu/Inventory.visible = true
			for items in inventory:
				inventory_space.add_item(str(items[0] + "(" + items[1] + ")"))
			
@onready var inventory_space = $Menu/Inventory/PanelContainer/ItemList
func _process(delta: float) -> void:
	if is_multiplayer_authority():
		_camera_pivot.global_position = self.global_position
		var ones = health % 10
		var tens = floor(health / 10) % 10
		var hundreds = (health / 100) % 10
		#health_tells goes hundreds, tens, ones
		health_tells[2].clear()
		health_tells[0].clear()
		health_tells[1].clear()
		health_tells[2].add_text(str(ones))
		health_tells[1].add_text(str(tens))
		health_tells[0].add_text(str(hundreds))
		rpc("remote_set_username",username)
		username = GlobalLists.username
		var listpos = GlobalLists.usernames.get(name)
		if listpos != username:
			GlobalLists.usernames.set(name,username)
		if $turn_based_player/main_menu/move_window.button_pressed:
			var pos = get_viewport().get_mouse_position()
			pos.x -= 314
			pos.y += 32
			turnbased_menu.position = pos
		if $turn_based_player/notifications/move_window.button_pressed:
			var pos = get_viewport().get_mouse_position()
			pos.x -= 100
			pos.y += 16
			$turn_based_player/notifications.position = pos
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
	if event is InputEventMouseMotion and is_multiplayer_authority() and can_move:
		_camera_pivot.rotation.x -= event.relative.y * mouse_sensitivity
		# Prevent the camera from rotating too far up or down.
		_camera_pivot.rotation.x = clampf(_camera_pivot.rotation.x, -tilt_limit, tilt_limit)
		_camera_pivot.rotation.y += -event.relative.x * mouse_sensitivity
	if event is InputEventJoypadMotion and is_multiplayer_authority() and can_move:
		var look_dir = Vector2(Input.get_joy_axis(0,JOY_AXIS_RIGHT_X),Input.get_joy_axis(0,JOY_AXIS_RIGHT_Y)).normalized()
		_camera_pivot.rotation.x -= look_dir.y * mouse_sensitivity
		_camera_pivot.rotation.x = clampf(_camera_pivot.rotation.x, -tilt_limit, tilt_limit)
		_camera_pivot.rotation.y += -look_dir.x * mouse_sensitivity * 10


# Turn Based Starts Here, prepare thyself

@onready var turnbased_menu = $turn_based_player/main_menu
@onready var notification_menu = $turn_based_player/notifications
@onready var portrait = $turn_based_player/Player_Stats/HBoxContainer/Player_Stats/VBoxContainer/HBoxContainer/PanelContainer/TextureRect
@onready var list_one = $turn_based_player/main_menu/main_menu/PanelContainer/HBoxContainer/ItemList
@onready var list_two = $turn_based_player/main_menu/main_menu/PanelContainer/HBoxContainer/ItemList2
@onready var knower = $turn_based_player/RichTextLabel
@onready var health_tells = [$turn_based_player/Player_Stats/HBoxContainer/Player_Stats/VBoxContainer/stats/VBoxContainer/Inner_Thigh/Health/Bar/HBoxContainer/HP_Hundreds, $turn_based_player/Player_Stats/HBoxContainer/Player_Stats/VBoxContainer/stats/VBoxContainer/Inner_Thigh/Health/Bar/HBoxContainer/HP_TENS, $turn_based_player/Player_Stats/HBoxContainer/Player_Stats/VBoxContainer/stats/VBoxContainer/Inner_Thigh/Health/Bar/HBoxContainer/HP_ONES]
@onready var sp_tells = [$turn_based_player/Player_Stats/HBoxContainer/Player_Stats/VBoxContainer/stats/VBoxContainer/Outer_Thigh/Health/Bar/HBoxContainer/SP_Hundreds,$turn_based_player/Player_Stats/HBoxContainer/Player_Stats/VBoxContainer/stats/VBoxContainer/Outer_Thigh/Health/Bar/HBoxContainer/SP_Tens,$turn_based_player/Player_Stats/HBoxContainer/Player_Stats/VBoxContainer/stats/VBoxContainer/Outer_Thigh/Health/Bar/HBoxContainer/SP_Ones]
var fight_button = preload("res://assets/images/fight.PNG")
var act_button = preload("res://assets/images/act.PNG")
var item_button = preload("res://assets/images/item.PNG")
var team_button = preload("res://assets/images/team.PNG")
var buttons = {
	"fight": preload("res://assets/images/fight.PNG"),
	"act": preload("res://assets/images/act.PNG"),
	"item": preload("res://assets/images/item.PNG"),
	"team": preload("res://assets/images/team.PNG"),
	"Count_Up": preload("res://assets/images/Count-up.PNG"),
	"Rush_Hour": preload("res://assets/images/Rush_Hour.PNG"),
	"Punch" : preload("res://assets/images/Punch.PNG"),
	"Minimum_Effort" : preload("res://assets/images/Minimum Effort.PNG"),
	"Company_Investment": preload("res://assets/images/Company_Investment.PNG"),
	"Hired_Help" : preload("res://assets/images/Hired-Help.PNG"),
	"Aftermath": preload("res://assets/images/Aftermath.PNG"),
	"Fake_Identity": preload("res://assets/images/Fake_Identity.PNG")
}
var in_fight = false
var uses = []
var self_class = "Cashier"
func set_class(profession : String):
	self_class = profession
func logger(text : String):
	knower.clear()
	knower.text = text
func reset_actions():
	list_one.clear()
	list_one.add_item("",buttons.get("fight"))
	list_one.add_item("",buttons.get("act"))
	list_one.add_item("",buttons.get("item"))
	list_one.add_item("",buttons.get("team"))
	list_two.clear()
# Path is formatted like, [Class,Type,Name]
# So Count up is stored [Cashier,Fight,Count_Up]
# If you just want to access generally the fight class for Cashier use the path, [Cashier,Fight]

@rpc("any_peer")
func sync_fight(position,enemy):
	if in_fight:
		$CPUParticles3D.visible = true
	else:
		$CPUParticles3D.visible = false
	if is_multiplayer_authority():
		$CPUParticles3D.visible = false
	
	can_move = false
	await get_tree().create_timer(0.1).timeout
	
	little_guy.rotation.y = 0
	little_guy.rotation.y = 120

func get_actions(path : Array):
	var size = path.size()
	print(size)
	knower.clear()
	logger("Moving Buttons to: " + str(path))
	var zero_path = path[0]
	var class_root : Dictionary = GlobalLists.abilities.get(zero_path)
	var type_root : Dictionary
	if size != 1:
		var one_path = path[1]
		type_root = class_root.get(one_path)
	else:
		type_root = class_root
	var list_one_amount = 0
	var list_two_amount = 0
	list_one.clear()
	list_two.clear()
	for value in type_root.values():
		var ability_name = type_root.find_key(value)
		print(ability_name)
		if list_one_amount < 4:
			list_one_amount += 1
			print(uses.find(ability_name))
			if uses.find(ability_name) == -1:
				uses.append(ability_name)
				uses.append(20)
			var selectable = true
			list_one.add_item("",buttons.get(ability_name),false)
			continue
		if list_one_amount == 4 and list_two_amount < 4:
			print("list two ", ability_name)
			list_two_amount += 1
			print(uses.find(ability_name))
			if uses.find(ability_name) == -1:
				uses.append(ability_name)
				uses.append(20)
			var selectable = true
			if uses.get(uses.find(ability_name) + 1) == 0:
				selectable = false
			list_two.add_item("",buttons.get(ability_name),false)

var fight_instance
var effects = {}
func start_fight(enemy : Node):
	if is_multiplayer_authority():
		can_move = false
		rpc("sync_fight",self.global_position,enemy)
		rpc("start_fight_remote",self,str(enemy.name),str(enemy.get_parent().name))
		var instance = load("res://scenes/fight_prototype/scene.tscn").instantiate()
		instance.left_fighters.append([str(self.name),"player"])
		instance.right_fighters.append([str(enemy.name),"enemy"])
		fight_instance = instance
		instance.world = world.world
		rpc("add_close")
		#Play Animations
		get_parent().add_child(instance)
		await get_tree().create_timer(0.1).timeout
		enemy.in_fight = true
		enemy.can_move = false
		enemy.local_fight = true
		enemy.set_collision_layer_value(1,false)
		enemy.fight_instance = instance
		enemy.rpc("sync_vars",false)
		world.get_node("all_things").visible = false
		little_guy.rotation.y = 0
		little_guy.rotation.y = 120
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		camera.current = false
		instance.camera.enabled = true
func play_animation(anim):
	pass

# We will store all active fights in array
# It will be stored like [Instance,StarterPlayer]
func join_fight(fight):
	# we need to check and find the instance and then compute all of the information
	# think of a way to do that with how it is structured
	var scene = get_parent().get_node(str(fight[0]))
	scene.left_fighters.append([str(self.name),"player"])
	waiting = true
	can_move = false
	fight[3] = str(name)
	scene.not_local = false
	print("player has tried to join a fight!")
	#stored index will do rest in scene
	scene.visible = true
	scene.localplayer = ["left",scene.left_fighters.find([str(self.name),"player"])]
	scene.rpc("join_fight",[str(self.name),"player"],scene.left_fighters.find([str(self.name),"player"]))
	#should we have the functions for the fight scene run client side or server side

@rpc("call_remote")
func start_fight_remote(player,enemy,enemy_parent):
	self.visible = false
	self.set_collision_layer_value(1,false)
	var enemy_instance = get_parent().get_node(enemy_parent)
	var instance = load("res://scenes/fight_prototype/scene.tscn").instantiate()
	instance.left_fighters.append(str(self.name))
	instance.right_fighters.append(enemy)
	enemy_instance = enemy_instance.get_main()
	enemy_instance.local_fight = false
	instance.not_local = true
	fight_instance = instance
	#Play Animations
	get_parent().add_child(instance)
	await get_tree().create_timer(0.1).timeout

@rpc("any_peer")
func add_close():
	var instance = load("res://scenes/enter_fight.tscn").instantiate()
	get_parent().add_child(instance)
	instance.global_position = self.global_position
	var fight = inst_to_dict(fight_instance)
	var check = inst_to_dict(self)
	instance.fight = [fight_instance.name,fight,check,name]



@rpc("call_remote")
func reawaken():
	self.set_collision_layer_value(1,true)
	self.visible = true

func death():
	await get_tree().create_timer(0.1).timeout
	rpc("reawaken")
	if health >= 0:
		$turn_based_player.visible = false
		can_move = true
		world.get_node("all_things").visible = true
		get_parent().get_node("all_things").visible = true
		camera.current = true
		self.global_position = Vector3(0,100,0)
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		$turn_based_player.visible = false
		can_move = true
		fight_instance.end_fight()
		world.get_node("all_things").visible = true
		camera.current = true
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func turn():
	logger("Your Turn")
	list_one.clear()
	list_two.clear()
	reset_actions()
	for item in list_one.item_count:
		print(item)
		list_one.set_item_selectable(item,false)
		list_one.set_item_disabled(item,false)
		print(list_one.is_item_disabled(item))
	for item in list_two.item_count:
		print(item)
		list_two.set_item_selectable(item,false)
		list_two.set_item_disabled(item,false)
func not_turn():
	print("not turn")
	for item in list_one.item_count:
		list_one.set_item_selectable(item,false)
		list_one.set_item_disabled(item,true)
		print(list_one.is_item_disabled(item))
	for item in list_two.item_count:
		list_two.set_item_selectable(item,false)
		list_two.set_item_disabled(item,true)
		print(list_two.is_item_disabled(item))
# Max Per list is 4 buttons
func _on_item_list_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	print(index)
	var clicked = buttons.find_key(list_one.get_item_icon(index))
	match clicked:
		"fight":
			get_actions([self_class,"Fight"])
		"act":
			pass
		"item":
			pass
		"team":
			pass
		"Count_Up":
			fight_instance.run_action(str(self.name),"Count_Up")
		"Punch":
			show_test()
	if second_menu:
		fight_instance.run_action(str(self.name),"Punch",fight_instance.enemies[index])
		second_menu = false

func _on_item_list_2_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	pass # Replace with function body.

func damage(amount):
	health -= amount
var second_menu = false
func show_test():
	list_one.clear()
	list_two.clear()
	print(fight_instance.show_test)
	for entity in fight_instance.show_test:
		print("here", entity)
		var node = get_parent().get_node(entity)
		if node == null:
			var world = get_parent()
			node = world.get_node(entity)
			if node == null:
				node = fight_instance.get_node(entity)
		if is_instance_valid(node):
			fight_instance.show_test.remove_at(fight_instance.show_test.find(entity))
		list_one.add_item("",node.get_main().sub_tex)
	await get_tree().create_timer(0.1).timeout
	second_menu = true

@rpc("any_peer")
func sync_turn_based_actions(position,fight_instance_name,playername):
	if playername == name:
		world.get_node("all_things").visible = false
		self.global_position = position
		can_move = false
		$turn_based_player.visible = true
		var fight = get_parent().get_node(fight_instance_name)
		fight_instance = fight
		fight_instance.visible = true
		var world_enum = world.world
		match world_enum:
			world_type.the_void:
				print("void")
				var instance = load("res://scenes/void_town.tscn").instantiate()
				instance.position = Vector3(0,-2,5.782)
				fight_instance.add_child(instance)
		fight_instance.camera.current = true
		camera.current = false
		little_guy.rotation = Vector3.ZERO
		little_guy.rotation.y = 0
		little_guy.rotation.x = 120
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		waiting = false

@rpc("any_peer")
func show_enemy(enemy_name,player_name):
	if player_name == name:
		var enemy = get_parent().get_node(enemy_name)
		enemy.in_fight = true
		enemy.can_move = false
		enemy.local_fight = true

@rpc("any_peer")
func show_player(player_name,ext_player_name):
	if player_name == name:
		var play = get_parent().get_node(ext_player_name)
		print(play.name)
		play.visible = true
		print(play.visible)

var preloaded_enemy = preload("res://scenes/enemy_base.tscn")


func add_item(item_name : String, amount : int, item_instance : Node):
	if inventory.size() > 16:
		for item in inventory:
			if item[0] == item_name:
				item[1] += 1
			else:
				inventory.append([item_name,amount])
		item_instance.rpc("kill")
	else:
		return

func remove_item(index : int ,amount : int):
	pass

func index_items():
	pass


func _on_options_pressed() -> void:
	$Menu/Buttons.visible = false
	$"Menu/Options Window".visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_mobile_toggled(toggled_on: bool) -> void:
	ProjectSettings.set_setting("global/mobile",toggled_on)


func _on_controller_toggled(toggled_on: bool) -> void:
	ProjectSettings.set_setting("global/controller",toggled_on)


func _on_fov_value_changed(value: float) -> void:
	camera.fov = 55 + value


func _on_meny_pressed() -> void:
	$Menu.visible = true




func take_attack(time : float,enemy_name : String, damage_scale : Array):
	var enemy = get_parent().get_node("world").get_node(enemy_name)
	if enemy == null:
		enemy = fight_instance.get_node(enemy_name)
	enemy.walk_up(self.global_position)
	await get_tree().create_timer(1.0).timeout
	var timer = get_tree().create_timer(time)
	var dodge_time = 0
	var good = time / 2
	var constipated = time / 4
	var okay = time / 1.5
	while timer.time_left > 0:
		if Input.is_action_just_pressed("ui_accept"):
			dodge_time = timer.time_left
	if dodge_time >= good and dodge_time > constipated:
		damage(damage_scale[0])
	elif dodge_time < constipated:
		damage(damage_scale[1])
	else:
		damage(damage_scale[2])

@onready var item_scene = preload("res://scenes/item.tscn")
# 1 arg, item name
func drop_item(item_name):
	var instance = item_scene.instantiate()
	
	instance.item_name = item_name 
	get_parent().add_child(instance)
	
