extends Label

# Round to number of decimal places
func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $StartTimer.time_left > 0:
		visible = true
		# When this timer is running, Engine.time_scale is set very low, so we need to adjust
		# Multiply the time remaining by an arbitrary number to scale it to about 3
		var time_to_display = round_to_dec($StartTimer.time_left * 75, 0)
		# If the math works out to be above 3, trim down to 3.
		if time_to_display > 3: time_to_display = 3
		text = str(time_to_display)
	else:
		visible = false
