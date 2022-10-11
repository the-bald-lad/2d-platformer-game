extends Actor

# Happens only when the object is first called, similar to an initialiser function in standard OOP programming
func _ready():
	set_physics_process(false)
	velocity.x = -speed.x

# Only triggered when an object enters the hitbox, as well as only being affected by the selected mask
func _on_Hit_Detection_body_entered(body):
	if body.global_position.y > get_node("Hit Detection").global_position.y:
		return 
	get_node("CollisionShape2D").set_deferred("disabled", true) # Removes collsion for enemy, so that player can go through enemy as soon as it has been removed
	queue_free()
	print("Enemy has died!")

# Happens every frame
func _physics_process(delta):
	velocity.y += gravity * delta
	if is_on_wall():
		velocity.x *= -1.0 # Flips enemy
	velocity.y = move_and_slide(velocity, FLOOR_NORMAL).y
