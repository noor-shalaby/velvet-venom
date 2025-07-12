class_name Pickup
extends Area2D


@export var animation_speed := 0.1


func _on_body_entered(body: Node2D):
	if body is Player:
		var tween: Tween = get_tree().create_tween().set_parallel(true)
		tween.tween_property(self, "scale", Vector2.ZERO, animation_speed)
		tween.tween_property(self, "modulate:a", 0.0, animation_speed)
		tween.connect("finished", queue_free)
