extends Node2D


func _on_area_2d_body_entered(body):
	# If the ball is in the slow mo zone, slow down time
	if body.is_in_group("ball"):
		Engine.time_scale = GameSettings.slow_mo_scale


func _on_area_2d_body_exited(body):
	# If the ball has left the zone, set time to normal speed
	if body.is_in_group("ball"):
		Engine.time_scale = GameSettings.game_time_scale
