extends RigidBody2D

signal goal_scored(team)

@onready var basic_ball_sprite = preload("res://assets/sprites/basic_ball.png")
@onready var white_ball_sprite = preload("res://assets/sprites/white_ball.png")
@onready var sprite2D = $Sprite2D
@onready var collision_shape = $CollisionShape2D
@onready var particles = $GPUParticles2D
@onready var impact_timer = $ImpactTimer

const MAX_SPEED = 550

var has_played_collision_sound = false
var bounds = {
	"max_x": 640,
	"min_x": 0,
	"max_y": 360,
	"min_y": 0
}


func _ready():
	set_contact_monitor(true)  # Enable contact monitoring
	set_max_contacts_reported(5)
	sprite2D.texture = basic_ball_sprite
	sprite2D.visible = true


func _process(_delta):
	var colliding_bodies = get_colliding_bodies()
	
	# Check to see if the ball has collided with a goal
	for body in colliding_bodies:
		if body.is_in_group("goal"):
			# Ask the goal for its team
			var team_name = body.get_team_name()
			# Emit a signal with the team number
			if team_name == 1:
				emit_signal("goal_scored", 1)
			elif team_name == 2:
				emit_signal("goal_scored", 2)
			
			# Freeze and briefly change to the white ball sprite
			sprite2D.texture = white_ball_sprite
			self.freeze = true
			impact_timer.start()
	
	# If there was any collision, play a sound
	if colliding_bodies.size() > 0:
		if not has_played_collision_sound:
			# Find a good pitch for the bounce sound based on velocity
			var average_velocity = (linear_velocity.x + linear_velocity.y) / 2
			var desired_pitch = 1.2 - (0.4 * (average_velocity / MAX_SPEED))
			SoundManager.play_sound("bounce02", -15, desired_pitch)
			has_played_collision_sound = true
	else:
		has_played_collision_sound = false


func _integrate_forces(state):
	# Check for screen wrap
	if global_position.x > bounds["max_x"]: global_position.x = bounds["min_x"]
	if global_position.x < bounds["min_x"]: global_position.x = bounds["max_x"]
	if global_position.y > bounds["max_y"]: global_position.y = bounds["min_y"]
	if global_position.y < bounds["min_y"]: global_position.y = bounds["max_y"]
	
	if abs(linear_velocity.x) > MAX_SPEED:
		state.linear_velocity.x = sign(linear_velocity.x) * MAX_SPEED
	
	if abs(linear_velocity.y) > MAX_SPEED:
		state.linear_velocity.y = sign(linear_velocity.y) * MAX_SPEED


func resize_ball(given_scale):
	collision_shape.scale = Vector2(given_scale, given_scale)
	var DEFAULT_SPRITE_SCALE = 0.333
	sprite2D.scale = Vector2(DEFAULT_SPRITE_SCALE * given_scale, DEFAULT_SPRITE_SCALE * given_scale)


func set_bounds(given_bounds):
	bounds = given_bounds


func _on_impact_timer_timeout():
	sprite2D.visible = false
	particles.emitting = true
