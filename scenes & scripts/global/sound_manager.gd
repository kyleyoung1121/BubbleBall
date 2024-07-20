# SoundManager.gd

extends Node


@onready var background_music_player = $BackgroundMusicPlayer


# Dictionary to store preloaded sounds
var sounds = {}
var tracks = {}
var track_list = []
var track_number_playing = 0
var track_dimmed = false
var track_dim_amount = -10
var sfx_that_dim = ["goal", "win"]

func _ready():
	# Preload all sound effects
	preload_audio()
	track_list = tracks.keys()
	play_track(1) # Indexed starting at 1 (to match UI)
	update_settings()


func preload_audio():
	# Sound Effects
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
	# Music Tracks
	tracks["mashup"] = preload("res://assets/audio/music/mashup.mp3")
	tracks["chiptune_grooving"] = preload("res://assets/audio/music/chiptune_grooving.mp3")
	tracks["cruising"] = preload("res://assets/audio/music/cruising.mp3")
	tracks["glitch_manor"] = preload("res://assets/audio/music/glitch_manor.mp3")
	tracks["loop_19"] = preload("res://assets/audio/music/loop_19.mp3")
	tracks["loop_20"] = preload("res://assets/audio/music/loop_20.mp3")
	tracks["pixel_party"] = preload("res://assets/audio/music/pixel_party.mp3")


func play_sound(sound_name: String, volume_db: float = 0.0, pitch_scale: float = 1.0):
	if sounds.has(sound_name):
		var sound_instance = AudioStreamPlayer.new()
		sound_instance.stream = sounds[sound_name]
		
		# Adjust sfx volume by initial value, master volume, and sfx volume
		sound_instance.volume_db = volume_db
		sound_instance.volume_db += (30 * GameSettings.get("master_volume") / 100) - 14
		sound_instance.volume_db += (30 * GameSettings.get("sfx_volume") / 100) - 14
		
		# If the master or music volume is set to 0, zero out the volume, just to be sure
		if (GameSettings.get("master_volume") == 0 or GameSettings.get("sfx_volume") == 0):
			sound_instance.volume_db = -100
		
		# Adjust the pitch, and begin playing the audio
		sound_instance.pitch_scale = pitch_scale
		add_child(sound_instance)
		sound_instance.play()
		
		# Connect the finished signal to remove the sound instance after it plays
		sound_instance.finished.connect(_on_sound_finished.bind(sound_instance))
		
		# If this sfx wants to dim the music track, do so, and make it promise to undo it after completion
		if sound_name in sfx_that_dim:
			dim_track()
			sound_instance.finished.connect(undim_track)


# If the game settings pertaining to audio are modified, update our audio accordingly
func update_settings():
	# Adjust music volume by initial value, master volume, and music volume
	background_music_player.volume_db = 0
	background_music_player.volume_db += (30 * GameSettings.get("master_volume") / 100) - 25
	background_music_player.volume_db += (30 * GameSettings.get("music_volume") / 100) - 25
	
	# If the master or music volume is set to 0, zero out the volume, just to be sure
	if (GameSettings.get("master_volume") == 0 or GameSettings.get("music_volume") == 0):
		background_music_player.volume_db = -100
	
	# If the track number has changed, change to that track
	if (not track_number_playing == GameSettings.music_track):
		play_track(GameSettings.music_track)


func play_track(requested_track_number):
	# Play the requested track (adjust down, as the first track is 1, not 0)
	background_music_player.stream = tracks[track_list[requested_track_number-1]]
	background_music_player.play()
	track_number_playing = requested_track_number


func dim_track():
	if not track_dimmed:
		background_music_player.volume_db += track_dim_amount
		track_dimmed = true


func undim_track():
	# Restore to normal volume (remove the dim effect)
	if track_dimmed:
		background_music_player.volume_db -= track_dim_amount
		track_dimmed = false


func _on_sound_finished(sound_instance: AudioStreamPlayer):
	remove_child(sound_instance)
	sound_instance.queue_free()
