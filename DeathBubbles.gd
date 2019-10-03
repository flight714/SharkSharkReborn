extends Sprite

export (Color) var color = ColorN("white")
export (float) var custom_scale = 2.0

func _ready():
	modulate = color
	scale *= custom_scale
	$AnimationPlayer.play("play_death")

# warning-ignore:unused_argument
func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()