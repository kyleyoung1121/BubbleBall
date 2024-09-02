extends Label


# Round to number of decimal places
func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $StartTimer.time_left > 0:
		visible = true
		text = str(int($StartTimer.time_left)+1)
	else:
		visible = false
