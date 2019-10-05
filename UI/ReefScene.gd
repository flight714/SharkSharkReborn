extends TextureRect

signal bubbles
signal scene_ended

onready var bubbles = $Reef/Bubbles

var player_one_score = 0
var player_one_lives = 5

var crustacean_y_position

var crustaceans = []

var death_bubbles = preload("res://DeathBubbles.tscn")

var RNG = RandomNumberGenerator.new()

var spawn_points_east = PoolVector2Array()
var spawn_points_west = PoolVector2Array()
var spawn_points_north = PoolVector2Array()
var spawn_points_shark = PoolVector2Array()

func _ready():
	randomize()
# warning-ignore:return_value_discarded
	connect("bubbles", SoundController, "play_sound")
	play_bubbles($Reef/Bubbles.position)
	yield(get_tree().create_timer(0.5), "timeout")
	emit_signal("bubbles", "bubbles")
	$ScoreLabel.text = str(player_one_score)
	$LivesLabel.text = str(player_one_lives)
	
	crustacean_y_position = get_viewport().size.y - (get_viewport().size.y * 0.10)
	
	add_player_one(get_viewport().size/2)
	
	setup_spawn_points()
	#$NewSharkTimer.start()
	setup_playing_field()

# warning-ignore:unused_argument
func _process(delta):
	for i in get_tree().get_nodes_in_group("Fish"):
		if i == self:
			self.remove_from_group("Fish")
	for i in get_tree().get_nodes_in_group("Players"):
		if i == self:
			self.remove_from_group("Players")
	for i in get_tree().get_nodes_in_group("Sharks"):
		if i == self:
			self.remove_from_group("Sharks")

func _on_AnimationTimer_timeout():
	if $Reef/RightBush.frame > 0:
		$Reef/RightBush.frame = 0
	else:
		$Reef/RightBush.frame += 1
	
	if $Reef/LeftBush.frame > 0:
		$Reef/LeftBush.frame = 0
	else:
		$Reef/LeftBush.frame += 1

func _on_BubblesTimer_timeout():
	play_bubbles()
	yield(get_tree().create_timer(0.5), "timeout")
	emit_signal("bubbles", "bubbles")
	
func end_scene():
	$AnimationTimer.stop()
	$BubblesTimer.stop()
	$BubblesAnimation.stop()
	$NewFishTimer.stop()
	$NewSharkTimer.stop()
	reset_playing_field()
	emit_signal("scene_ended")
	
func get_random_x_below_screen():
	var screen = get_viewport()
	return Vector2(rand_range(0, screen.size.x), screen.size.y + 100)
	
func play_bubbles(bubbles_pos=get_random_x_below_screen()):
	bubbles.position = bubbles_pos
	bubbles.visible = true
	$Tween.interpolate_property($Reef/Bubbles, "position", bubbles_pos, Vector2(bubbles_pos.x, -600), 6.5, Tween.TRANS_LINEAR, Tween.EASE_OUT_IN)
	$Tween.start()
	$BubblesAnimation.start()

func _on_BubblesAnimation_timeout():
	var max_frames = (bubbles.vframes*bubbles.hframes) - 1
	if bubbles.frame == max_frames:
		bubbles.frame = 0
	else:
		bubbles.frame += 1

func _on_Tween_tween_all_completed():
	$BubblesAnimation.stop()
	bubbles.visible = false

func add_fish(new_fish : String, location : Vector2, starting_level=1):
	var fish = SceneLibrary.get_fish_at_level(new_fish, starting_level)
	add_child(fish)
	fish.connect("notify_sound", self, "request_sound")
	fish.connect("is_dead", self, "death_animation")
	fish.position = location
	add_child(fish)
	
func add_seahorse(location : Vector2):
	var new_seahorse = SceneLibrary.seahorse.instance()
	new_seahorse.position = location
	new_seahorse.connect("notify_sound", self, "request_sound")
	new_seahorse.connect("is_dead", self, "death_animation")
	add_child(new_seahorse)
	
func add_jellyfish(location : Vector2):
	var new_jellyfish = SceneLibrary.jellyfish.instance()
	new_jellyfish.position = location
	new_jellyfish.connect("notify_sound", self, "request_sound")
	new_jellyfish.connect("is_dead", self, "death_animation")
	add_child(new_jellyfish)
	
func add_shark(location : Vector2):
	var new_shark = SceneLibrary.get_shark()
	new_shark.connect("notify_sound", self, "request_sound")
	new_shark.connect("is_dead", self, "on_shark_death")
	new_shark.position = location
	add_child(new_shark)
	
func add_random_fish_at_range(location: Vector2, min_range=1, max_range=5):
	var new_random_fish = SceneLibrary.get_random_fish_at_range(min_range, max_range)
	new_random_fish.connect("notify_sound", self, "request_sound")
	new_random_fish.connect("is_dead", self, "death_animation")
	new_random_fish.position = location
	add_child(new_random_fish)

func add_player_one(location : Vector2, new_size=1):
	var player = SceneLibrary.get_player()
	player.fish_size = new_size
	player.connect("notify_sound", self, "request_sound")
	player.connect("points_scored", self, "update_player_score")
	player.connect("is_dead", self, "death_animation")
	player.connect("update_lives", self, "update_player_lives")
	player.add_to_group("Players")
	add_child(player)
	player.position = location

func request_sound(sound_type, priority):
	SoundController.play_sound(sound_type, priority)
	
func update_player_score(score):
	player_one_score += score
	$ScoreLabel.text = str(player_one_score)
	
func update_player_lives(value):
	player_one_lives += value
	$LivesLabel.text = str(player_one_lives)
	
func death_animation(location : Vector2, is_player=false):
	var new_death_bubbles = death_bubbles.instance()
	new_death_bubbles.position = location
	if is_player == true:
		new_death_bubbles.color = ColorN("red")
	add_child(new_death_bubbles)
	if is_player == true:
		yield(get_tree().create_timer(1.2), "timeout")
		resolve_player_death()

func player_kills_lobster(location : Vector2):
	death_animation(location)
	update_player_lives(1)
	
func add_crustacean(crustacean : Crustacean):
	add_child(crustacean)
	var position_option = [-50, get_viewport().size.x + 50]
	crustacean.position = Vector2(position_option[RNG.randi_range(0,1)], crustacean_y_position)
	crustacean.y_line = crustacean.transform.get_origin().y
# warning-ignore:return_value_discarded
	crustacean.connect("died_normal", self, "death_animation")
# warning-ignore:return_value_discarded
	crustacean.connect("died_from_player", self, "player_kills_lobster")
	crustaceans.append(crustacean)
	
func add_crab():
	var new_crab = SceneLibrary.crab.instance()
	add_crustacean(new_crab)
	
func add_lobster():
	var new_lobster = SceneLibrary.lobster.instance()
	add_crustacean(new_lobster)
	
func resolve_player_death():
	if player_one_lives > 0:
		$BubblesTimer.stop()
		reset_playing_field()
		play_bubbles(Vector2(get_viewport().size.x/2, get_viewport().size.y + 50))
		yield(get_tree().create_timer(0.5), "timeout")
		emit_signal("bubbles", "bubbles")
		add_player_one(get_viewport().size/2)
		$BubblesTimer.start()
		setup_playing_field()
	else:
		end_scene()
		$GameOverLabel.show()

func setup_spawn_points():
	var next_point = Vector2(-100, get_viewport().size.y -30)
	for _i in range(5):
		spawn_points_west.append(Vector2(next_point.x, next_point.y))
		next_point.y -= 80
	
	next_point = Vector2(get_viewport().size.x + 100, -30)
	for _i in range(5):
		spawn_points_east.append(Vector2(next_point.x, next_point.y))
		next_point.y -= 80
		
	next_point = Vector2(-70, -200)
	for _i in range(5):
		spawn_points_north.append(Vector2(next_point.x, next_point.y))
		next_point.x += 80
		
	spawn_points_shark.append_array([Vector2(-400, -500), Vector2(get_viewport().size.x + 400, -500)])

func reset_playing_field():
	for fish in get_tree().get_nodes_in_group("Fish"):
		fish.queue_free()

func add_fish_from_array(array : PoolVector2Array, min_level=1, max_level=3):
	for spot in array:
		var decision = RNG.randf()
		if decision > 0.5:
			add_random_fish_at_range(spot, min_level, max_level)

func setup_playing_field():
	var player_level = 1
	var min_level = 1
	if get_tree().get_nodes_in_group("Players").size() < 1:
		player_level = 1
	else:
		player_level = get_tree().get_nodes_in_group("Players")[0].fish_size
	if player_level > 1:
		min_level = player_level - 1
	add_fish_from_array(spawn_points_east, min_level, player_level+1)
	add_fish_from_array(spawn_points_north, min_level, player_level+1)
	add_fish_from_array(spawn_points_west, min_level, player_level+1)
	$NewFishTimer.wait_time = RNG.randf_range(4.0, 8.0)
	$NewFishTimer.start()
	$NewSharkTimer.start()

func _on_NewFishTimer_timeout():
	if get_tree().get_nodes_in_group("Fish").size() > 15:
		return
	var player_level = 1
	var special_fish = 0
	var spawn_array = [spawn_points_east, spawn_points_west, spawn_points_north]
	if get_tree().get_nodes_in_group("Players").size() > 0:
		player_level = get_tree().get_nodes_in_group("Players")[0].fish_size
	var fish_to_add = RNG.randi_range(1, player_level+2)
	var fish_pool = []
	for fish in get_tree().get_nodes_in_group("Fish"):
		if !get_tree().get_nodes_in_group("Players").has(fish):
			fish_pool.append(fish.fish_size)
	var lowest_size = 5
	if fish_pool.size() < 1:
		lowest_size = 1
	else:
		for size in fish_pool:
			if lowest_size >= size:
				lowest_size = size
	if player_level <= lowest_size:
		for _i in range(fish_to_add):
			add_fish_from_array(spawn_array[RNG.randi_range(0, 2)], 1, player_level)
	elif player_level > 2 and player_level < 5:
		fish_to_add += RNG.randi_range(1, 3)
		special_fish = RNG.randi_range(1, fish_to_add-1)
		for _i in range(special_fish):
			add_seahorse(spawn_array[RNG.randi_range(0, 2)][RNG.randi_range(0, 4)])
		for _i in range(fish_to_add - special_fish):
			add_fish_from_array(spawn_array[RNG.randi_range(0, 2)], player_level, 5)
	else:
		fish_to_add += RNG.randi_range(3, 5)
		special_fish = RNG.randi_range(1, fish_to_add-1)
		var jellyfish_amount = RNG.randi_range(0, special_fish)
		
		for _i in range(special_fish - jellyfish_amount):
			add_seahorse(spawn_array[RNG.randi_range(0, 2)][RNG.randi_range(0, 4)])
		for _i in range(jellyfish_amount):
			add_jellyfish(spawn_array[RNG.randi_range(0, 2)][RNG.randi_range(0, 4)])
		for _i in range(fish_to_add - special_fish):
			add_fish_from_array(spawn_array[RNG.randi_range(0, 2)], player_level-1, 5)
			
	if get_tree().get_nodes_in_group("Sharks").size() < 1 and $NewSharkTimer.is_stopped() == true:
		$NewSharkTimer.start(RNG.randf_range(6.0, 12.0))
	
	if player_level >= RNG.randi_range(1, 2) and crustaceans.size() <= 1:
		var choice = RNG.randf()
		if choice >= 0.5:
			add_lobster()
		else:
			add_crab()

# warning-ignore:unused_argument
func on_shark_death(location):
	$NewSharkTimer.start()

func _on_NewSharkTimer_timeout():
	if player_one_lives > 0 and get_tree().get_nodes_in_group("Sharks").size() < 1:
		add_shark(spawn_points_shark[RNG.randi_range(0,spawn_points_shark.size()-1)])
		$NewSharkTimer.wait_time = RNG.randf_range(6.5, 12.5)
