extends Actor

# Happens only when the object is first called, similar to an initialiser function in standard OOP programming
func _ready():
	set_physics_process(false)
	velocity.x = -speed.x

# Happens every frame
func _physics_process(delta):
	velocity.y += gravity * delta
	if is_on_wall():
		velocity.x *= -1.0 # Flips enemy
	velocity.y = move_and_slide(velocity, FLOOR_NORMAL).y

# Only triggered when an object enters the hitbox, as well as only being affected by the selected mask
func _on_Hit_Detection_body_entered(_body):
	# Removes collsion for enemy, so that player can go through enemy as soon as it has been removed
	get_node("CollisionShape2D").set_deferred("disabled", true) 
	
	queue_free()
	
	print(name, " has died!") # For testing purposes, so the enemy that has died is known.
