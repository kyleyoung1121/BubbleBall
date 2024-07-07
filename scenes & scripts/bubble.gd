extends Node2D

# Signal to emit when the bubble should apply an impulse to the ball
signal exploded

# Define the impulse to apply to the ball
const IMPULSE = 30.0

func _on_body_entered(body):
	if body.is_in_group("ball"):
		# Calculate the direction from the bubble to the ball
		var direction = (body.global_position - global_position).normalized()
		# Apply impulse to the ball
		body.apply_central_impulse(direction * IMPULSE)
		# Remove the bubble from the scene
		queue_free()
