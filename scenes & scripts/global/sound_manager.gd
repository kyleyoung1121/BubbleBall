# SoundManager.gd

extends Node

# Dictionary to store preloaded sounds
var sounds = {}

func _ready():
	# Preload all sound effects
	preload_sounds()

func preload_sounds():
	sounds["ball_bounce"] = preload("res://assets/audio/ball_bounce.mp3")
	sounds["countdown"] = preload("res://assets/audio/countdown.mp3")
	sounds["goal"] = preload("res://assets/audio/goal01.mp3")
	sounds["jump"] = preload("res://assets/audio/jump.mp3")
	sounds["pjump"] = preload("res://assets/audio/pjump.mp3")
	sounds["slide"] = preload("res://assets/audio/slide.mp3")
	sounds["start01"] = preload("res://assets/audio/start01.mp3")
	sounds["start02"] = preload("res://assets/audio/start02.mp3")
	sounds["ui_next"] = preload("res://assets/audio/ui_next.mp3")
	sounds["ui_back"] = preload("res://assets/audio/ui_back.mp3")
	sounds["win"] = preload("res://assets/audio/win01.mp3")


func play_sound(sound_name: String, volume_db: float = 0.0, pitch_scale: float = 1.0):
	if sounds.has(sound_name):
		var sound_instance = AudioStreamPlayer.new()
		sound_instance.stream = sounds[sound_name]
		# Further adjust the volume based on the master volume. dB change should be between -10 and +15
		sound_instance.volume_db = volume_db + (30 * GameSettings.get("master_volume") / 100) - 30
		sound_instance.pitch_scale = pitch_scale
		add_child(sound_instance)
		sound_instance.play()
		# Connect the finished signal to remove the sound instance after it plays
		sound_instance.finished.connect(_on_sound_finished.bind(sound_instance))


# Add this method to convert dB to linear scale
func db_to_linear(dB: float) -> float:
	return pow(10.0, dB / 20.0)

# Add this method to convert linear scale to dB
func linear_to_db(linear: float) -> float:
	if linear <= 0.0:
		return -float('inf')  # Return negative infinity if linear value is zero or less
	return 20.0 * log(linear) / log(10.0)


func _on_sound_finished(sound_instance: AudioStreamPlayer):
	remove_child(sound_instance)
	sound_instance.queue_free()
