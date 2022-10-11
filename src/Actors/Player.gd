extends position

# Global Variables
var direction:      = Vector2.ZERO
var player_frame:   = 0
var rotation_amount = 0.0 # To quickly adjust the rotation of the sprite
var tmp # So that the returned variable from the the change_scene function is assigned

# Checked when first loaded
onready var current_level: = get_tree().current_scene.filename
onready var mouse_pos:     = Vector2.ZERO

# Exported Variables
export var stomp_impulse: = 700.0

# Function called every frame
func _physics_process(_delta):
	#get_position() # Getting player position 
	var is_jump_interrupted: = Input.is_action_just_released("Jump") and velocity.y < 0.0 # Will return a bool with whether or not the player has stopped jumping
	
	direction = get_direction() # calls function to calculate player direction
	velocity  = calculate_velocity(velocity, direction, speed, is_jump_interrupted) # Calculates player velocity
	velocity  = move_and_slide(velocity, FLOOR_NORMAL) # Function to move player
	
	set_rotation(rotation_amount) # Sets rotation of sprite every frame

# Setting rotation so that the sprite is locked to facing the correct way
func set_rotation(amount: float):
	$".".rotation_degrees = amount # Gets parent node and sets rotation for parent and all children

# Calculating how much the player should move
func calulate_move_velocity(
	linear_velocity: Vector2,
	impulse: float
) -> Vector2:
	var out: = linear_velocity
	out.y    = -impulse
	return out

# To output the player position to the console
func get_position():
	pos.x = global_position.x # Gets x position
	pos.y = global_position.y # Gets y position
	if player_frame > 60: # Only outputs once every second
		print("Player position: " + str(pos))
		player_frame = 0
	else:
		player_frame += 1
		
# In order to calculate the movement of the player
func get_direction():
	return Vector2(
		Input.get_action_strength("Move_Right") - Input.get_action_strength("Move_Left"), # Calculates diection, with 1 being right and -1 being left
		-1.0 if Input.is_action_just_pressed("Jump") and is_on_floor() else 1.0 # Whether or not the player is jumping
	)

# To calculate how far the player should move
func calculate_velocity(
	linear_velocity: Vector2, 
	new_direction: Vector2,
	speed: Vector2,
	is_jump_interrupted: bool
) -> Vector2:
	var new_velocity:   = linear_velocity
	new_velocity.x      = speed.x * new_direction.x # calculating how much to move the x axis
	new_velocity.y     += gravity * get_physics_process_delta_time() # Compensating for frame delay
	if new_direction.y == -1.0:
		new_velocity.y  = speed.y * new_direction.y
	if is_jump_interrupted:
		new_velocity.y  = 0.0 # Stops jump if button is released before full jump
	return new_velocity

# So that the level can be reset
func reset():
	tmp = get_tree().change_scene(current_level) # Resets to current playing level

# Makes the player jump when touching the enemy stomp collision area (not used since gun added)
func _on_Enemy_Detection_area_entered(_area):
	velocity = calulate_move_velocity(velocity, stomp_impulse) 

# For the players death
func _on_Enemy_Detection_body_entered(_body):
	reset()

# For checking if the player has left the play area
func _on_Fall_Check_body_entered(_body):
	reset()
