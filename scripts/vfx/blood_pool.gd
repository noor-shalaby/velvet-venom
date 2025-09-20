class_name BloodPool
extends Area2D


@onready var sprite: Sprite2D = $Sprite
@onready var sprite2: Sprite2D = $Sprite2
@onready var collision_shape: CollisionShape2D = $CollisionShape
@onready var tween: Tween = create_tween().set_parallel(true)

func _ready() -> void:
	global_rotation_degrees = randf_range(-180.0, 180.0)
	sprite2.global_rotation_degrees = randf_range(-180.0, 180.0)
	
	scale.x = scale.x * randf_range(0.8, 1.2)
	scale.y = scale.x
	
	tween.tween_property(sprite, "scale", scale * 1.16, 4 * scale.x)
	tween.tween_property(self, "global_rotation_degrees", global_rotation_degrees + 4.0, 4)


func free_main_pool() -> void:
	sprite.queue_free()
	collision_shape.queue_free()
