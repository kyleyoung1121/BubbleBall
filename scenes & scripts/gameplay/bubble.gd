extends Node2D


# Signal to emit when the bubble should apply an impulse to the ball
signal exploded


# Define the impulse to apply to the ball
const IMPULSE = 70.0
const ORANGE_BUBBLE = preload("res://assets/sprites/orange_bubble.png")
const BLUE_BUBBLE = preload("res://assets/sprites/blue_bubble.png")


var team_name = null


# If the bubble is collided with, delete the bubble and apply force if it touched the ball
func _on_body_entered(body):
	if body.is_in_group("ball"):
		# Calculate the direction from the bubble to the ball
		var direction = (body.global_position - global_position).normalized()
		# Cancel part of the ball's momentum
		body.linear_velocity = Vector2(body.linear_velocity.x * 0.5, body.linear_velocity.y * 0.5)
		# Apply impulse to the ball
		body.apply_central_impulse(direction * IMPULSE)
		# Remove the bubble from the scene
	queue_free() # Bubble is deleted upon any collision, ball or not.


# Given a team, assign the sprite & collision layers.
func set_team(given_team):
	team_name = given_team
	if given_team == 1: 
		$Sprite2D.texture = ORANGE_BUBBLE
		$Area2D.collision_layer = 0b00000001  # Layer 1 (Team 1)
		$Area2D.collision_mask = 0b00000110  # Collide with Layer 2 & 3 (Team 2 & Ball)
	elif given_team == 2:
		$Sprite2D.texture = BLUE_BUBBLE
		$Area2D.collision_layer = 0b00000010  # Layer 2 (Team 2) 
		$Area2D.collision_mask = 0b00000101  # Collide with Layer 1 (Team 1 & Ball)
	else:
		print("Bubble: Invalid team number")
