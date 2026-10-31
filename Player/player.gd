extends CharacterBody3D

@onready var head: Node3D = $Head
@onready var health_label: Label = $UI/HealthLabel
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var raycast: RayCast3D = $Head/Camera3D/RayCast3D
@onready var muzzle_flash: GPUParticles3D = $Head/Camera3D/Pistol/MuzzleFlash

@export var move_speed := 10.0
@export var jump_strength := 13.0
@export var gravity := -30.0
@export var mouse_sensitivity := 0.005
@export var health := 5

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		head.rotation.x = clamp(head.rotation.x, -PI/2, PI/2)
		
	if event.is_action_pressed("escape"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if event.is_action_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
	if Input.is_action_just_pressed("left_click") \
			and anim_player.current_animation != "shoot":
		play_shoot_effects()
		if raycast.is_colliding():
			var hit_entity = raycast.get_collider()
			if hit_entity and hit_entity.is_in_group("zombies"):
				hit_entity.take_damage(1)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = jump_strength

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)
		velocity.z = move_toward(velocity.z, 0, move_speed)

	if anim_player.current_animation == "shoot":
		pass
	elif input_dir != Vector2.ZERO and is_on_floor():
		anim_player.play("walk")
	else:
		anim_player.play("idle")

	move_and_slide()
	
func take_damage(amount: int):
	health -= amount
	update_health_label(health)
	
	if health <= 2:
		health_label.modulate = Color.RED
	
	if health <= 0:
		respawn()

func respawn():
	get_tree().reload_current_scene.call_deferred()
	
func update_health_label(new_value):
	health_label.text = "Health: %s" % new_value
	
func play_shoot_effects():
	$ShootSFX.play()
	anim_player.stop()
	anim_player.play("shoot")
	muzzle_flash.restart()
	muzzle_flash.emitting = true
	
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "shoot":
		anim_player.play("idle")
