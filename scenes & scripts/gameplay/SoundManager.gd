# SoundManager.gd

extends Node

# Dictionary to store preloaded sounds
var sounds = {}

func _ready():
	# Preload all sound effects
	preload_sounds()

func preload_sounds():
	# Jump sounds
	sounds["bounce01"] = preload("res://assets/audio/bounce01.mp3")
	sounds["bounce02"] = preload("res://assets/audio/bounce02.mp3")
	sounds["bounce03"] = preload("res://assets/audio/bounce03.mp3")
	sounds["bounce04"] = preload("res://assets/audio/bounce04.mp3")
	sounds["bounce05"] = preload("res://assets/audio/bounce05.mp3")
	sounds["bounce06"] = preload("res://assets/audio/bounce06.mp3")
	# Start sounds
	sounds["start01"] = preload("res://assets/audio/start01.mp3")
	sounds["start02"] = preload("res://assets/audio/start02.mp3")
	sounds["start03"] = preload("res://assets/audio/start03.mp3")
	sounds["start04"] = preload("res://assets/audio/start04.mp3")
	# Additional sounds
	sounds["goal"] = preload("res://assets/audio/goal01.mp3")
	sounds["pop"] = preload("res://assets/audio/pop01.mp3")
	sounds["countdown"] = preload("res://assets/audio/countdown.mp3")
	sounds["win"] = preload("res://assets/audio/win01.mp3")
	sounds["ui_next"] = preload("res://assets/audio/ui_next01.mp3")
	sounds["ui_back"] = preload("res://assets/audio/ui_back01.mp3")
	
	# Add more sounds as needed

func play_sound(sound_name: String, volume_db: float = 0.0, pitch_scale: float = 1.0):
	if sounds.has(sound_name):
		var sound_instance = AudioStreamPlayer.new()
		sound_instance.stream = sounds[sound_name]
		sound_instance.volume_db = volume_db
		sound_instance.pitch_scale = pitch_scale
		add_child(sound_instance)
		sound_instance.play()
		# Connect the finished signal to remove the sound instance after it plays
		sound_instance.finished.connect(_on_sound_finished.bind(sound_instance))

func _on_sound_finished(sound_instance: AudioStreamPlayer):
	remove_child(sound_instance)
	sound_instance.queue_free()
