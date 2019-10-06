extends Node2D

var main_alpha = 1.0

func _ready():
	#fade_intro()
	pass
	
# warning-ignore:unused_argument
func _process(delta):
	$TextureRect.modulate.a = main_alpha

func fade_intro():
	$StartTween.interpolate_property(self, "main_alpha", 0.0, 1.0, 5.0, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$StartTween.start()
	
func start_one_player_game():
	get_tree().change_scene("res://UI/ReefScene.tscn")

func _on_Button_pressed():
	start_one_player_game()
