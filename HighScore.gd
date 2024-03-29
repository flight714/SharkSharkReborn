extends Node2D

var player_score = SceneLibrary.current_player_score
var score_table : Dictionary

onready var left_scores = $TextureRect/HBoxContainer/LeftScores
onready var right_scores = $TextureRect/HBoxContainer/RightScores

var test_RNG = RandomNumberGenerator.new()

func _ready():
	$TextureRect/PlayerScore.text = str(player_score)
	load_scores()
	
	score_table = create_new_score_dict()

func load_scores():
	pass
	
func create_new_score_dict():
	var new_score_table = {}
	for i in range(20):
		new_score_table[(i+1)] = test_RNG.randi_range(0, 500)
	return new_score_table
	
func update_score_table():
	#var keys = score_table.keys()
	var values = score_table.values()
	values.sort()
	print(values)
	# need to insert new player score
	
	if values.size() > 20:
		values.remove(0)

	

func switch_modes():
	$TextureRect/PlayerScore.hide()
	$TextureRect/ScoreMessage.hide()
	
	for i in range(10):
		set_score_box(left_scores.get_children()[i], (i+1), score_table[i+1]) 
		set_score_box(right_scores.get_children()[i], (i+1+10), score_table[i+1+10]) 
	
func set_score_box(label : Label, index : int, score : int):
	label.text = str(index) + ": " + str(score)

func _on_Button_pressed():
	get_tree().change_scene("res://MainMenu.tscn")
