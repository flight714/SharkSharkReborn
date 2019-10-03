extends "res://Pieces/Fish.gd"

var player_sprite_library = {
	1 : preload("res://assets/PlayerFish1.png"),
	2 : preload("res://assets/PlayerFish2.png"),
	3 : preload("res://assets/PlayerFish3.png"),
	4 : preload("res://assets/PlayerFish4.png"),
	5 : preload("res://assets/PlayerFish5.png")
	}

func _ready():
	pass

func switch_sprites():
	$Sprite.texture = player_sprite_library[fish_size]
	
func _input(event):
	if event.is_action_released("ui_accept"):
		pass