extends CharacterBody3D

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var model: MeshInstance3D = $"Zombie Running/Skeleton3D/Model"
@onready var self_sfx: AudioStreamPlayer = $SelfSFX
@onready var health_label: Label3D = $HealthLabel

@export var move_speed := 5.0
@export var health := 3

func _physics_process(delta: float) -> void:
	var current_position = global_transform.origin
	var next_position = nav_agent.get_next_path_position()
	var new_velocity = (next_position - current_position).normalized() * move_speed
	
	nav_agent.set_velocity(new_velocity)

func update_target_position(target_position):
	nav_agent.target_position = target_position

func _on_navigation_agent_3d_target_reached() -> void:
	pass

func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = velocity.move_toward(safe_velocity, .25)
	move_and_slide()

func _on_hit_detector_body_entered(body: Node3D) -> void:
	if body.is_in_group("players") and body.has_method("take_damage"):
		body.take_damage(1)
		
func take_damage(amount: int):
	health -= amount
	update_health_label(health)
	
	if health <= 0:
		queue_free()

func _on_timer_timeout() -> void:
	self_sfx.play()
	
func update_health_label(new_value):
	health_label.text = "Health: %s" % new_value
