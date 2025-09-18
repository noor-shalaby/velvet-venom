extends Node2D


@export var animation_duration: float = 0.5

const TEXTURES: Dictionary[String, CompressedTexture2D] = {
	"gun": preload(Constants.FILE_UIDS.weapon_tex_gun),
	"machinegun": preload(Constants.FILE_UIDS.weapon_tex_machinegun),
	"shotgun": preload(Constants.FILE_UIDS.weapon_tex_shotgun)
}
@export var drop_range_min: float = 64.0
@export var drop_range_max: float = 128.0


func _ready() -> void:
	var random_dir: Vector2 = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
	var tween: Tween = create_tween().set_parallel(true).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	tween.tween_property(self, "global_position", global_position + randf_range(drop_range_min, drop_range_max) * random_dir, animation_duration)
	tween.tween_property(self, "global_rotation_degrees", global_rotation_degrees + randf(), animation_duration)
	tween.tween_property(self, "global_scale", global_scale * 0.9, animation_duration)
