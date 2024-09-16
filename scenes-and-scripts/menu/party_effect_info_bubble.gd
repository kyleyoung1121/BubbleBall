extends Node2D

@onready var effect_label = $InfoBubble/Label

var upper_position = 0
var lower_position = -100


func _ready():
	effect_label.text = ""


func _process(delta):
	pass


func show_effect_name(name):
	effect_label.text = name
