extends PanelContainer
var time = 0
var effect_name = ""
var timer : SceneTreeTimer
@onready var time_obj = $main/titleandtime/time
@onready var title = $main/titleandtime/title
@onready var desc = $main/titleandtime/desc
@onready var icon  = $main/TextureRect
var preload_icons = {
    "default" : preloader.get_resource("hat")
}

#rageful - increase damage reduce healing; constipation - slowness; doctor: increase health; pacifist: reduce damage increase healing; gambler: decrease luck; dealer: increase luck; diarrhea: increase speed; malpractice: poison; 
#var effects = ["rageful", "constipation", "doctor", "pacifist", "gambler", "dealer", "diarrhea", "malpractice"]

var effects = {
    "rageful": "+atk, -healing",
    "constipation": "-speed" ,
    "doctor": "+healing",
    "pacifist": "-atk, +healing",
    "gambler": "-luck, -psluck",
    "dealer": "+luck, ",
    "diarrhea": "+speed",
    "malpractice": "-healing"
}


#init function to set values
    # change icon 
    # create timer
    # on timeout queue free
func _init():
    if !preload_icons.get(effect_name):
        icon.texture = preload_icons.get("default")
    else:
        icon.texture = preload_icons.get(effect_name)
    timer = get_tree().create_timer(time)

func _process(delta):
    if timer:
        time_obj.clear()
        time_obj.text = timer.wait_time - timer.time_left
        title.clear()
        title.text = effect_name
        desc.clear()
        desc.text = effects.get(effect_name)
