extends Node

# General
var team_lives = 3
var game_time_scale = 0.85
var slow_mo_scale = 0.45
var game_mode = "casual"

# Players
var player_mass = 0.4

# Ball
var ball_scale = 0.8 # 0.4 - 2 , 0.8 preferred
var ball_mass = 0.2 # 0.1 - 0.5

# Bubbles
var allow_bubbles = true
var directional_bubbles = false
var max_bubbles = 1
var bubble_size = 1.2

# Platforms
var spin_speed = 1

# Party Mode Settings
var giant_ball = true
var tiny_ball = true
var always_slow_mo = true
var fast_mo = true
var no_bubbles = true
var three_bubbles = true
var five_bubbles = true
var unlimited_bubbles = true
var arrow_bubbles = true
var colorblind = true
var invisible_players = true

# Audio
var master_volume = 50
var music_volume = 50
var sfx_volume = 50
var mute = false
var music_track = 1
