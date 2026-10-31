extends Area3D

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("players") and body.has_method("eat"):
		body.eat()
		body.update_health_label(body.health)
		body.check_health_color()
		queue_free()
