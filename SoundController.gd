extends Node

var sound_path_dictionary = {
	"shark_entered" : ["res://assets/sounds/SharkEntered.wav"],
	"shark_moved" : ["res://assets/sounds/SharkMoved.wav"],
	"shark_died" : ["res://assets/sounds/SharkDied.wav"],
	"level_up" : ["res://assets/sounds/LevelUp.wav"],
	"died" : ["res://assets/sounds/Died.wav"],
	"bubbles" : ["res://assets/sounds/Bubbles1.wav","res://assets/sounds/Bubbles2.wav","res://assets/sounds/Bubbles3.wav"],
	"blip" : ["res://assets/sounds/Blip1.wav","res://assets/sounds/Blip2.wav","res://assets/sounds/Blip3.wav"]
	}
	
var AudioPlayers = [[AudioStreamPlayer.new(), false],[AudioStreamPlayer.new(), false],[AudioStreamPlayer.new(), false]]

func _ready():
	randomize()
	for i in range(AudioPlayers.size()):
		add_child(AudioPlayers[i][0])
	
func load_sound(player : AudioStreamPlayer, sound_path : String):
	player.stream = load(sound_path)
	
func load_sound_from_array(player : AudioStreamPlayer, sound_array : Array):
	if sound_array.size() < 2 and sound_array.size() > 0:
		load_sound(player, sound_array[0])
	elif sound_array.size() > 1:
		load_sound(player, sound_array[randi() % (sound_array.size())])
		
func play_sound(sound_type : String, priority=false):
	if !sound_path_dictionary.has(sound_type):
		return
	var sound_completed = false
	for i in range(AudioPlayers.size()):
		if AudioPlayers[i][0].playing == true:
			pass
		else:
			AudioPlayers[i][1] = priority
			load_sound_from_array(AudioPlayers[i][0], sound_path_dictionary[sound_type])
			AudioPlayers[i][0].play()
			sound_completed = true
			break
	if sound_completed == false and priority == true:
		for i in range(AudioPlayers.size()):
			if AudioPlayers[i][1] == false:
				AudioPlayers[i][1] = true
				load_sound_from_array(AudioPlayers[i][0], sound_path_dictionary[sound_type])
				AudioPlayers[i][0].play()
				sound_completed = true
				break
	
