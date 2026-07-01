extends RigidBody2D

@export var float_force := 15.0
@export var torque_force := 2

func _ready():
	gravity_scale = 0
	linear_damp = 4
	angular_damp = 8

func _physics_process(delta):

	# flutuar
	apply_force(Vector2(0, -float_force))

	# tentar ficar vertical
	apply_torque(rotation * -torque_force)
