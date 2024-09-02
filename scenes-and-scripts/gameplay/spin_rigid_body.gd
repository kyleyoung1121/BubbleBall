extends RigidBody2D

@export var spin_speed = 2.0


func _ready():
	# Ensure that the platform remains in place as it spins
	self.gravity_scale = 0.0
	self.linear_damp = 100000.0  # Prevent linear movement
	self.angular_damp = 0.0  # Allow free rotation


func _integrate_forces(state: PhysicsDirectBodyState2D):
	# Continuously apply torque to maintain spin, even in case of small collisions
	angular_velocity = spin_speed
