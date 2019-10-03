extends Area2D

class_name Barrier

# warning-ignore:unused_class_variable
export (bool) var player_only_barrier = false
export (bool) var block_vertical = false
export (bool) var block_horizontal = false
export (float) var damper = 1.0

func _ready():
	pass


# warning-ignore:unused_argument
func _on_Barrier_area_entered(area):
	if area.has_method("get_size") and area.is_alive:
		if area.is_player == true and player_only_barrier == true or player_only_barrier == false:
			if block_vertical:
				area.velocity.y = -area.velocity.y * damper
			if block_horizontal:
				area.velocity.x = -area.velocity.x * damper
