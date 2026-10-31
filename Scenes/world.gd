extends Node

@onready var player: CharacterBody3D = $Player

func _physics_process(delta: float) -> void:
	get_tree().call_group("zombies", "update_target_position", player.global_transform.origin)
