extends Area2D

class_name Fish

export (int) var fish_size = 1
export (int) var max_size = 5
var experience_points = 0.0
var current_speed = 0
export (float) var max_speed = 150
export (float) var acceleration = 150
export (Color) var fish_color = ColorN("yellow")
export (bool) var is_player = false
# player bools looks pretty crude but works for now
export (bool) var is_first_player = false
export (bool) var is_second_player = false
# warning-ignore:unused_class_variable
export (String) var player_name = "player_one"
export (float) var fish_alertness = 1.5

export (float) var move_damper = 0.01

export (Texture) var sprite

var is_onscreen = false

export (int) var health = 1

var is_alive = false
var swimming = false
var should_leave_scene = false
var persistent_target = Vector2.ZERO

var velocity = Vector2()

var ignore_list = []

signal is_dead(position, is_pl)
signal level_up
signal notify_sound(sound_type, priority)
signal points_scored(points, player)
signal update_lives(value)


var draw_point : Vector2

func _ready():
	randomize()
	if fish_size > max_size:
		fish_size = max_size
	elif fish_size < 1:
		fish_size = 1
	if sprite:
		$Sprite.texture = sprite
	$Sprite.modulate = fish_color
	
	$Sprite.hframes = 2
	$Sprite.vframes = 1
	
	if fish_size > 1:
		for _i in range(fish_size):
			scale *= 1.1
			max_speed *= 1.1
			acceleration *= 1.1
			fish_alertness *= 0.90
	if fish_size < 1:
		scale *= 0.8
		
	if is_player == true:
		$Sprite.texture = SceneLibrary.player_sprite_library[fish_size]
		
	$MovementTimer.wait_time = fish_alertness + rand_range(-0.15, 0.15)
	add_to_group("Fish")
	
	if !$CollisionShape2D.shape:
		var new_shape = CapsuleShape2D.new()
		new_shape.radius = 10 + (fish_size*1.1)
		new_shape.height = 10 + (fish_size*1.1)
		$CollisionShape2D.shape = new_shape

func _process(delta):
	is_alive = health > 0
	
	if experience_points >= fish_size + 1:
		emit_signal("level_up")
	
	if is_alive == false:
		position.y += 50 * delta
	
	if is_alive == true:
		position += velocity * delta
		current_speed = velocity.length()
			
		if current_speed > 0:
			velocity -= velocity*move_damper
			swimming = true
		else:
			swimming = false
			
		animate()
		if is_player == false:
			check_movement()
		
		if current_speed > max_speed:
			velocity = velocity.normalized() * max_speed
			
		$Sprite.flip_h = velocity.x > 0
		
	if persistent_target != Vector2.ZERO:
		if abs(to_local(position).x - persistent_target.x) <= 50 and abs(to_local(position).y - persistent_target.y) <= 50:
			persistent_target = Vector2.ZERO
			if should_leave_scene == true:
				should_leave_scene = false



func set_destination(new_vector : Vector2, power : float):
	var new_direction = to_local(position).direction_to(new_vector) * (acceleration * power)
	$RayCast2D.cast_to = new_direction
	$RayCast2D.enabled = true
	$RayCast2D.force_raycast_update()
	if $RayCast2D.is_colliding():
		var barrier = $RayCast2D.get_collider()
		if barrier is Barrier:
			if barrier.player_only_barrier == true and is_player == true or barrier.player_only_barrier == false:
				var move_length = acceleration*power
				var barrier_pos = to_local($RayCast2D.get_collision_point())
				var new_length = move_length - (move_length - to_local(position).distance_to(barrier_pos))
				var new_ratio = new_length/move_length
				new_direction *= new_ratio
	velocity += new_direction
	$RayCast2D.enabled = false
	
func get_health():
	return health
	
func get_size():
	return fish_size
	
func animate():
	if swimming:
		if $AnimationTimer.time_left > 0:
			pass
		else:
			$AnimationTimer.start()

func _on_Fish_area_entered(area):
	if area.has_method("resolve_battle") and !ignore_list.has(area):
		ignore_list.append(area)
		resolve_battle(area)
	
	if get_tree().get_nodes_in_group("Sharks").has(area.get_parent()):
		var shark = area.get_parent()
		if shark.is_alive == true and is_alive == true:
			emit_signal("points_scored", 500)
		elif shark.is_alive == false and is_alive == true:
			emit_signal("notify_sound", "shark_died", true)
			emit_signal("points_scored", 2000)
	
func resolve_battle(incoming_fish):
	if incoming_fish.fish_size > fish_size:
		health = 0
		if is_player == true:
			emit_signal("update_lives", -1)
		send_sound_alert("died", true, true)
		emit_signal("is_dead", position, is_player)
		call_deferred("queue_free")
	elif incoming_fish.fish_size < fish_size:
		experience_points += fish_size*0.5
		if is_player:
			emit_signal("points_scored", fish_size*100)
		send_sound_alert("blip", false, false)
	elif incoming_fish.fish_size == fish_size:
		if is_player and incoming_fish.is_player == false:
			experience_points += fish_size*0.5
			emit_signal("points_scored", fish_size*100)
			send_sound_alert("blip", true, false)
		elif !is_player and incoming_fish.is_player:
			health = 0
			emit_signal("is_dead", position, is_player)
			call_deferred("queue_free")
			
func _draw():
	if draw_point:
		draw_circle(draw_point, 5.0, fish_color)

func _on_AnimationTimer_timeout():
	if $Sprite.frame == 0:
		$Sprite.frame = 1
	else:
		$Sprite.frame = 0

func check_movement():
	if is_player == false and is_alive:
		if $MovementTimer.time_left <= 0:
			$MovementTimer.start()

func _on_MovementTimer_timeout():
	if is_alive:
		var decision = find_next_location()
		set_destination(decision[0], decision[1])
		$MovementTimer.start()
	
func find_next_location():
	var near_objects = []
	var is_in_danger = false
	var found_target = false
	var pos = to_local(global_position)
	
	if should_leave_scene == true and !persistent_target:
		var two_options = [-500, get_viewport().size.x+500]
		var x_pos = two_options[randi()%2]
		persistent_target = to_local(Vector2(x_pos, -500))
		return [pos.direction_to(persistent_target), 0.5]
		
	if should_leave_scene == true and persistent_target != null:
		return [pos.direction_to(persistent_target), 0.5]
	
	for f in get_tree().get_nodes_in_group("Fish"):
		if f != self:
			if pos.distance_to(to_local(f.position)) < (200 * (fish_size*0.5)):
				near_objects.append(f)
	
	if near_objects.size() > 0:
		for o in near_objects:
			if o.has_method("get_size"):
				if o.get("fish_size") > fish_size:
					return [-pos.direction_to(to_local(o.position)), 1.0]
	if !is_in_danger and near_objects.size() > 0:
		for o in near_objects:
			if o.has_method("get_size"):
				if o.fish_size < fish_size:
					return [pos.direction_to(to_local(o.position)), 0.95]
					
	if !is_in_danger and !found_target:
		var center = to_local(get_viewport_rect().size/2)
		var target = Vector2(center.x + rand_range(-500, 500), center.y + rand_range(-200, 200))
		if pos.distance_to(center) <= rand_range(50, 200):
			target.x += rand_range(-center.x*4, center.x*4)
			target.y += rand_range(-center.y*4, center.y*4)
		if abs(to_global(position).y - get_viewport().size.y) <= 70 and target.y >= 0:
			target.y -= target.y - rand_range(60, 150)
		return [target, 0.5]
			
				
func blink_animation():
	for _i in range(3):
		yield(get_tree().create_timer(0.15), "timeout")
		$Sprite.modulate.a = 0.0
		yield(get_tree().create_timer(0.15), "timeout")
		$Sprite.modulate.a = 1.0
		

func _on_Fish_level_up():
	if fish_size + 1 <= max_size:
		fish_size += 1
		scale *= 1.2
		max_speed *= 1.10
		acceleration *= 1.10
		$MovementTimer.wait_time *= 0.90
		if is_player == true:
			$Sprite.texture = SceneLibrary.player_sprite_library[fish_size]
			$Sprite.scale *= 0.9
	else:
		emit_signal("update_lives", 1)
	experience_points = 0.0
	if is_player == true:
		blink_animation()
		send_sound_alert("level_up", true, true)
	
func _input(event):
	if event.is_action_pressed("player_one_action") and is_first_player == true:
		var location = to_local(event.get("position"))
		set_destination(location, 1.0)
		
	if event.is_action_pressed("player_two_action") and is_second_player == true:
		var location = to_local(event.get("position"))
		set_destination(location, 1.0)
		
	# Keyboard stuff
	if event.is_action_pressed("ui_down") and is_first_player == true:
		set_destination(Vector2.DOWN, 1.0)
	if event.is_action_pressed("ui_up") and is_first_player == true:
		set_destination(Vector2.UP, 1.0)
	if event.is_action_pressed("ui_left") and is_first_player == true:
		set_destination(Vector2.LEFT, 1.0)
	if event.is_action_pressed("ui_right") and is_first_player == true:
		set_destination(Vector2.RIGHT, 1.0)
	
func _on_VisibilityNotifier2D_screen_entered():
	is_onscreen = true

func _on_VisibilityNotifier2D_screen_exited():
	is_onscreen = false
	
func send_sound_alert(sound_type, priority=false, player_only=false):
	if is_player == false and player_only == true:
		return
	elif is_onscreen == false and priority == false:
		return
	else:
		emit_signal("notify_sound", sound_type, priority)
