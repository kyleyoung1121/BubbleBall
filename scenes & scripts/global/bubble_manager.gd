extends Node


var current_bubble: Node = null


func set_current_bubble(bubble):
	if current_bubble != null:
		current_bubble.queue_free()
	current_bubble = bubble
