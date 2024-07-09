extends Node2D


@onready var start_timer = $CountDownText/StartTimer
@onready var count_down_text = $CountDownText


func match_ready():
	# Slow down time to as close to zero as possible (timer requires it not be 0)
	Engine.time_scale = 0.01
	start_timer.start()


func match_begin():
	# Set time scale to normal
	Engine.time_scale = 1


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_start_timer_timeout():
	match_begin()

