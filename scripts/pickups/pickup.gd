class_name Pickup
extends Area2D


@export var animation_dur: float = 0.1


func _on_body_entered(body: Node2D):
	if body is Player:
		picked_up()


func picked_up():
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2.ZERO, animation_dur)
	tween.tween_property(self, "modulate:a", 0.0, animation_dur)
	tween.connect("finished", queue_free)
