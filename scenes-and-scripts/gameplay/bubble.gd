extends Node2D

# Signal to emit when the bubble should apply an impulse to the ball
signal exploded

# Define the impulse to apply to the ball
const IMPULSE = 60.0
const ROTATION_SPEED = 0.001

# Load scene components
# NOTE: when the bubble is created in the player script, these must be referred to manually
@onready var bubble_animation = $BubbleAnimation
@onready var collision2d = $Area2D/CollisionShape2D
@onready var arrow = $Arrow


var player
var blast_direction
var team_name = null
var is_popping = false


func _process(delta):
	if not GameSettings.use_directional_bubbles:
		rotation += ROTATION_SPEED


func _ready():
	if not GameSettings.use_directional_bubbles:
		rotation = randi_range(0,10)
		arrow.visible = false
	else:
		arrow.visible = true
		if blast_direction:
			arrow.rotation = blast_direction.angle()


# If the bubble is collided with, delete the bubble and apply force if it touched the ball
func _on_body_entered(body):
	# If the bubble is already in the pop animation, do not allow any extra collisions
	if is_popping:
		return
	
	if body.is_in_group("ball"):
		# Determine what direction the ball should be pushed
		var direction
		if not GameSettings.use_directional_bubbles:
			# Calculate the direction from the bubble to the ball
			direction = (body.global_position - global_position).normalized()
		else:
			if blast_direction:
				direction = blast_direction
				
		# Cancel part of the ball's momentum
		body.linear_velocity = Vector2(body.linear_velocity.x * 0.5, body.linear_velocity.y * 0.5)
		# Apply impulse to the ball
		if direction:
			body.apply_central_impulse(direction * IMPULSE)
	
	# Play the pop animation (afterwards, the bubble will be removed)
	trigger_pop()
	SoundManager.play_sound("bounce06", -25, 1.6)


func trigger_pop():
	is_popping = true
	collision2d.disabled = true
	arrow.visible = false
	if team_name == 1:
		bubble_animation.play("orange_pop")
	else:
		bubble_animation.play("blue_pop")


func set_blast_direction(direction):
	blast_direction = direction


# Given a team, assign the sprite & collision layers.
func set_team(given_team):
	team_name = given_team
	if given_team == 1: 
		$Area2D.collision_layer = 0b00000001  # Layer 1 (Team 1)
		$Area2D.collision_mask = 0b00000110  # Collide with Layer 2 & 3 (Team 2 & Ball)
	elif given_team == 2:
		$Area2D.collision_layer = 0b00000010  # Layer 2 (Team 2) 
		$Area2D.collision_mask = 0b00000101  # Collide with Layer 1 (Team 1 & Ball)
	else:
		print("Bubble: Invalid team number")
	
	# Begin the idle animation
	if team_name == 1:
		$BubbleAnimation.play("orange_idle")
	else:
		$BubbleAnimation.play("blue_idle")


func _on_animated_sprite_2d_animation_finished():
	if is_popping:
		
		# Try to remove self from the player's bubble list
		if player:
			var player_bubbles = PlayerManager.get_player_data(player, "bubbles")
			if self in player_bubbles:
				player_bubbles.erase(self)
				PlayerManager.set_player_data(player, "bubbles", player_bubbles)
		
		# Finally, remove the bubble
		queue_free()
