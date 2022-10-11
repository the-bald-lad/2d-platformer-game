extends Level

onready var anim_player: AnimationPlayer = get_node("AnimationPlayer")


# When a relevant mask enters the collectables hitbox
func _on_body_entered(_body):
	anim_player.play("Fade")
	Score += 1
