extends Marker2D


# Hide the team text. This should only be seen in the editor.
func _ready():
	$Label.visible = false
