extends Label

func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $StartTimer.time_left > 0:
		visible = true
		var time_to_display = round_to_dec($StartTimer.time_left * 75, 0)
		if time_to_display > 3: time_to_display = 3
		text = str(time_to_display)
	else:
		visible = false
