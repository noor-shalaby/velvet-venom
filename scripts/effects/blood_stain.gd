extends Sprite2D


func _ready():
	global_rotation_degrees = randf_range(-180.0, 180.0)
	scale.x = scale.x * randf_range(0.8, 1.2)
	scale.y = scale.x
	var tween = create_tween()
	tween.tween_property(self, "scale", scale * 1.16, 4)
