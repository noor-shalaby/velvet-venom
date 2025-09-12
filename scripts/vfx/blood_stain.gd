extends Sprite2D


func _ready() -> void:
	global_rotation_degrees = randf_range(-180.0, 180.0)
	scale.x += scale.x * randf_range(-Constants.RANDOFACTO, Constants.RANDOFACTO)
	scale.y = scale.x
	create_tween().tween_property(self, "scale", scale * 1.16, 4)
