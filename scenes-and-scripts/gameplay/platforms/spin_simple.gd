extends Node2D

@export var spin_speed = 1.0

func _process(delta):
	self.rotation += spin_speed * delta * GameSettings.spin_speed
