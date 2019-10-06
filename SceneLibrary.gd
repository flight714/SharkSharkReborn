extends Node

var fish_libary_standard = {
	"snapper" : preload("res://Pieces/FishTypes/Snapper1.tscn"),
	"narrow" : preload("res://Pieces/FishTypes/AltSnapper.tscn"),
	"angel_beta" : preload("res://Pieces/FishTypes/AngelFishBeta.tscn"),
	"orangesnapper" : preload("res://Pieces/FishTypes/OrangeSnapper.tscn"),
	"yellowminnow" : preload("res://Pieces/FishTypes/YellowMinnow.tscn"),
	"diamond" : preload("res://Pieces/FishTypes/DiamondFish.tscn"),
	"purpleangel" : preload("res://Pieces/FishTypes/PurpleAngel.tscn"),
	"bluefish" : preload("res://Pieces/FishTypes/BlueFish.tscn")
	}
	
# warning-ignore:unused_class_variable
var player_sprite_library = {
	1 : preload("res://assets/PlayerFish1.png"),
	2 : preload("res://assets/PlayerFish2.png"),
	3 : preload("res://assets/PlayerFish3.png"),
	4 : preload("res://assets/PlayerFish4.png"),
	5 : preload("res://assets/PlayerFish5.png")
	}

var shark = preload("res://Pieces/Shark.tscn")
var player = preload("res://Pieces/FishTypes/PlayerFish.tscn")
# warning-ignore:unused_class_variable
var jellyfish = preload("res://Pieces/FishTypes/JellyFish.tscn")
# warning-ignore:unused_class_variable
var seahorse = preload("res://Pieces/FishTypes/Seahorse.tscn")
# warning-ignore:unused_class_variable
var crab = preload("res://Pieces/FishTypes/Crab.tscn")
# warning-ignore:unused_class_variable
var lobster = preload("res://Pieces/FishTypes/Lobster.tscn")

var fish_type_array : Array

var current_player_score = 0
var high_score_scene = preload("res://HighScore.tscn")

func _ready():
	fish_type_array = fish_libary_standard.keys()
	randomize()

func get_shark(level=0, locked=false):
	var new_shark = shark.instance()
	if level > 0:
		new_shark.fish_size = level
		if locked == true or level > new_shark.fish_size:
			new_shark.max_size = level
	return new_shark

func get_player(player_number=1, color_override=null):
	if player_number < 1:
		player_number = 1
	elif player_number > 2:
		player_number = 2
	
	var new_player = player.instance()
	if player_number == 1:
		new_player.fish_color = ColorN("yellow")
	elif player_number == 2:
		new_player.fish_color = ColorN("red")
	if color_override != null:
		new_player.fish_color = color_override
	new_player.is_player = true
	new_player.is_first_player = true
	return new_player

func get_fish_at_level(fish_type : String, fish_level=1):
	if fish_libary_standard.has(fish_type) == false:
		return
	var new_fish = fish_libary_standard[fish_type].instance()
	new_fish.fish_size = fish_level
	return new_fish
	
func get_fish_at_range(fish_type : String, min_level=1, max_level=5):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	return get_fish_at_level(fish_type, rng.randi_range(min_level, max_level))
	
func get_random_fish_at_level(fish_level=1):
	var fish_name = fish_type_array[randi()%fish_type_array.size()]
	return get_fish_at_level(fish_name, fish_level)
	
func get_random_fish_at_range(min_level=1, max_level=5):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	return get_random_fish_at_level(rng.randi_range(min_level, max_level))
	
func go_to_high_score(score):
	current_player_score = score
	get_tree().change_scene("res://HighScore.tscn")