extends Node2D


@export var slow_percent: float = GameSettings.slow_mo_scale
@export var normal_percent: float = GameSettings.game_time_scale


func _on_area_2d_body_entered(body):
	if body.is_in_group("ball"):
		Engine.time_scale = slow_percent


func _on_area_2d_body_exited(body):
	if body.is_in_group("ball"):
		Engine.time_scale = normal_percent
