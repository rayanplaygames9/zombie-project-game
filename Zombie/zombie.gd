extends CharacterBody3D

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

@export var move_speed := 5.0

func _physics_process(delta: float) -> void:
	var current_position = global_transform.origin
	var next_position = nav_agent.get_next_path_position()
	var new_velocity = (next_position - current_position).normalized() * move_speed
	
	nav_agent.set_velocity(new_velocity)

func update_target_position(target_position):
	nav_agent.target_position = target_position

func _on_navigation_agent_3d_target_reached() -> void:
	print("in range")

func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = velocity.move_toward(safe_velocity, .25)
	move_and_slide()
