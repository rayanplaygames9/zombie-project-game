extends Node

@onready var player: CharacterBody3D = $Player

@export var zombie_scene: PackedScene

func _physics_process(delta: float) -> void:
	get_tree().call_group("zombies", "update_target_position", player.global_transform.origin)


func spawn_zombie_r():
	var zombie = zombie_scene.instantiate()
	zombie.position = Vector3(randf_range(-40, 40), 1, randf_range(-40, 40))
	get_tree().current_scene.add_child(zombie)


func _on_spawn_zombie_timer_timeout() -> void:
	spawn_zombie_r()
