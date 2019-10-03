extends "res://Pieces/Fish.gd"

var attack_location : Vector2
var is_visible = false
var x_dir : int
var new_dir : int

func _ready():
	health = 8
	self.add_to_group("Sharks")
	
# warning-ignore:unused_argument
func _process(delta):
	if $Sprite.flip_h == false:
		$LeftTail/CollisionShape2D.disabled = true
		$LeftMainCollision.disabled = true
		$RightTail/CollisionShape2D.disabled = false
		$CollisionShape2D.disabled = false
	if $Sprite.flip_h == true:
		$LeftTail/CollisionShape2D.disabled = false
		$LeftMainCollision.disabled = false
		$RightTail/CollisionShape2D.disabled = true
		$CollisionShape2D.disabled = true
		
	if velocity.x > 0:
		new_dir = 1
	if velocity.x < 0:
		new_dir = -1
	if new_dir != x_dir and is_alive:
		x_dir = new_dir
		send_sound_alert("shark_moved", false, false)
			
		
	$DeathSprite.flip_h = $Sprite.flip_h
	check_death_status()
		
func react_to_tail_bite(area : Fish):
	health -= area.fish_size*0.5
	area.experience_points += fish_size*0.5
	if health > 0:
		send_sound_alert("blip", false, false)
		attack_location = to_local(area.position)
		$ReactionTimer.start()
		if should_leave_scene == true:
			should_leave_scene = false
		$RetreatTimer.start()
		area.emit_signal("points_scored", 50)
		yield($ReactionTimer, "timeout")
		set_destination(attack_location, 1.0)
	else:
		area.emit_signal("points_scored", 2000)
		send_sound_alert("shark_died", true, false)
		emit_signal("is_dead", position)

func _on_LeftTail_area_entered(area):
	if area is Fish and area != self:
		react_to_tail_bite(area)

func _on_RightTail_area_entered(area):
	if area is Fish and area != self:
		react_to_tail_bite(area)
	
func check_death_status():
	if !is_alive:
		$CollisionShape2D.disabled = true
		$RightTail/CollisionShape2D.disabled = true
		$LeftTail/CollisionShape2D.disabled = true
		$LeftMainCollision.disabled = true
		$Sprite.visible = false
		$DeathSprite.visible = true
	
	else:
		$Sprite.visible = true
		$DeathSprite.visible = false

func _on_VisibilityNotifier2D_screen_exited():
	is_visible = false
	if is_alive == false:
		queue_free()
	$RetreatTimer.start()

func _on_VisibilityNotifier2D_screen_entered():
	is_visible = true
	send_sound_alert("shark_entered", true, false)
	$RetreatTimer.start()


func _on_RetreatTimer_timeout():
	should_leave_scene = !should_leave_scene
