extends Node

# General
var team_lives = 3
var game_time_scale = 0.85
var slow_mo_scale = 0.45
var game_mode = "casual"

# Players
var player_mass = 0.4

# Ball
var ball_scale = 0.8
var ball_mass = 0.2

# Bubbles
var use_bubbles = true
var use_directional_bubbles = false
var max_bubbles = 1
var bubble_size = 1.2

# Platforms
var spin_speed = 1

# Party Mode Settings
var effect_frequency = 30
var apply_effect_per_round = true
var lock_effect = false
var party_effects = {
	"giant_ball": true,
	"tiny_ball": true,
	"always_slow_mo": true,
	"fast_mo": true,
	"no_bubbles": true,
	"three_bubbles": true,
	"five_bubbles": true,
	"unlimited_bubbles": true,
	"directional_bubbles": true,
	"invisible_players": true,
}

# Audio
var master_volume = 50
var music_volume = 50
var sfx_volume = 50
var mute = false
var music_track = 1
