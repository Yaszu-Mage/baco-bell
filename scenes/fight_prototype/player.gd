extends Marker2D
var type = ""
var side = []
var side_tag = ""
var position_in_line
@onready var sprite = $AnimatedSprite2D
var enemy_side = []
var is_in_sprite = true
var fight = get_parent()
signal scored
var health = 10
var sp = 10
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fight = get_parent()
	match position_in_line:
		0:
			print("match 0")
			if side_tag == "left":
				self.global_position = fight.line_left_instances[0].global_position
			if side_tag == "right":
				self.global_position = fight.line_right_instances[0].global_position
		1:
			print("match 1")
			if side_tag == "left":
				self.global_position = fight.line_left_instances[1].global_position
			if side_tag == "right":
				self.global_position = fight.line_right_instances[1].global_position
		2:
			print("match 2")
			if side_tag == "left":
				self.global_position = fight.line_left_instances[2].global_position
			if side_tag == "right":
				self.global_position = fight.line_right_instances[2].global_position



# Called every frame. 'delta' is the elapsed time since the previous frame.
@onready var centercast = $turn_based_player/checker/top/center
@onready var leftcast = $turn_based_player/checker/top/center
@onready var rightcast = $turn_based_player/checker/top/center
var is_valid = 0
# 0 = no collisions, 1 = one of the side collisions, 2 = middle collision
func _process(delta: float) -> void:
	if centercast.is_colliding():
		is_valid = 2
	if rightcast.is_colliding() and !centercast.is_colliding() or leftcast.is_colliding() and !centercast.is_colliding():
		is_valid = 1
	if !centercast.is_colliding() and !rightcast.is_colliding() and !leftcast.is_colliding():
		is_valid = 0


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
var fight_instance = fight
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
		if side_tag == "left":
			fight_instance.run_action(str(self.name),"Punch",fight_instance.right_fighters[index])
		if side_tag == "right":
			fight_instance.run_action(str(self.name),"Punch",fight_instance.left_fighters[index])
		second_menu = false

var second_menu = false
func show_test():
	list_one.clear()
	list_two.clear()
	fight_instance = fight
	if side_tag == "left":
		for fighter in fight_instance.right_fighters:
			var enemy = fighter[0]
			match enemy:
				"cuber":
					list_one.add_item("", load("res://assets/images/cuber.png"))
				"player":
					print("player")
	await get_tree().create_timer(0.1).timeout
	second_menu = true


func _on_item_list_2_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	print(index)
	var clicked = buttons.find_key(list_two.get_item_icon(index))
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


@onready var notification_menu_text = $turn_based_player/notifications/main/sub/VBoxContainer/actualtext
func display_message(message : String):
	notification_menu_text.add_text("
" + message)

@onready var checker = $turn_based_player/checker
@onready var minigame_player = $turn_based_player/AnimationPlayer
func animate(attack : String, enemy_position : Vector2, enemy : String):
	fight_instance = get_parent()
	match attack:
		"Punch":
			var old_pos = global_position
			var tween = create_tween()
			sprite.play("walk")
			tween.tween_property(self,"global_position",enemy_position,1)
			await tween.finished
			sprite.stop()
			await get_tree().create_timer(0.1).timeout
			#Insert minigame
			checker.visible = true
			minigame_player.play("active")
			await pressed
			if is_valid == 2:
				fight.damage = 2
				#send signal back to fight scene for damage
			elif is_valid == 1:
				fight.damage = 1
			else:
				fight.damage = 0
			fight.damage_calculated.emit()
			checker.visible = false
			$shmack.play()
			sprite.play("attack")
			await sprite.animation_finished
			sprite.play_backwards("walk")
			print("walking backwards")
			var tween2 = create_tween()
			sprite.play_backwards("walk")
			tween2.tween_property(self,"global_position",old_pos,1)
			await tween2.finished
			sprite.play("idle")
			reset_actions()

signal pressed
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		pressed.emit()

func dodge(length : float, dmg_scale : Array):
	var timer = get_tree().create_timer(length)
	var correct_time = length / 2
	var bad_time = length / 3
	var okay_time = length / 1.5
	var stopped_time
	await pressed
	stopped_time = timer.time_left
	if stopped_time >= correct_time and stopped_time > bad_time:
		damage(dmg_scale[0]) # scale 0
	elif stopped_time < bad_time:
		damage(dmg_scale[1]) # scale 1
	else:
		damage(dmg_scale[2]) # scale 2
	fight = get_parent()
	fight.damage_calculated.emit()

func damage(amount):
	health -= amount