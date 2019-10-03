extends Area2D

class_name Crustacean

export (float) var y_line = 80
export (float) var jump_strength = 1.0
export var fish_size = 6
var velocity = Vector2()
# warning-ignore:unused_class_variable
var is_player = false


var is_alive = true
var is_falling = false
var is_jumping = false

signal died_normal(location)
signal died_from_player(location)

func _ready():
	randomize()
	$AnimationPlayer.play("play")
	add_to_group("Fish")
	$MovementTimer.start(rand_range(1.0, 3.0))

func _process(delta):
	
	if is_alive == true:
		position += (velocity * delta)
		exert_gravity()
		
		if is_jumping == true:
			fish_size = 6
		if is_falling == true:
			fish_size = 3
		if is_falling == false and is_jumping == false:
			fish_size = 6
	
	is_falling = velocity.y > 0
	is_jumping = velocity.y < 0
	

func set_y_line():
	y_line = transform.get_origin().y

func resolve_battle(incoming_fish : Fish):
	if incoming_fish.fish_size > fish_size:
		is_alive = false
		if incoming_fish.is_player == true:
			emit_signal("died_from_player", position)
		else:
			emit_signal("died_normal", position)
		queue_free()
	elif incoming_fish.fish_size < fish_size:
		pass
	elif incoming_fish.fish_size == fish_size:
		if incoming_fish.is_player:
			is_alive = false
			emit_signal("died_from_player", position)
			queue_free()
		
func exert_gravity():
	if position.y < y_line:
		velocity.y += 5
		
	else:
		position.y = y_line
	
func jump():
	if is_falling == false:
		velocity.x = 0
		velocity.y = -340*jump_strength

func _on_Crustacean_area_entered(area):
	if area is Fish:
		resolve_battle(area)

func _on_MovementTimer_timeout():
	if is_alive == true:
		check_movement()
		$MovementTimer.start(rand_range(3.0, 5.0))
		
func check_movement():
	var screen_center = get_viewport().size.x/2
	
	$RayCast2D.force_raycast_update()
	if $RayCast2D.get_collider() is Fish and $RayCast2D.get_collider().fish_size <= 6:
		jump()
			
	else:
		if abs(to_global(position).x - screen_center) > rand_range(100, 400):
			if to_global(position).x < screen_center:
				velocity.x = rand_range(50, 80)
			else:
				velocity.x = rand_range(-50, -80)
		else:
			velocity.x = rand_range(-1, 1) * rand_range(30, 60)
	