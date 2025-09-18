extends Node2D

const TEXTURES: Dictionary[String, CompressedTexture2D] = {
	"gun": preload(Constants.FILE_UIDS.weapon_tex_gun),
	"machinegun": preload(Constants.FILE_UIDS.weapon_tex_machinegun),
	"shotgun": preload(Constants.FILE_UIDS.weapon_tex_shotgun)
}
const MIN_DROP_RANGE: float = 64.0
const MAX_DROP_RANGE: float = 128.0


func _ready() -> void:
	var random_dir: Vector2 = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
	var tween: Tween = create_tween().set_parallel(true).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	tween.tween_property(self, "global_position", global_position + randf_range(MIN_DROP_RANGE, MAX_DROP_RANGE) * random_dir, 0.5)
	tween.tween_property(self, "global_rotation_degrees", global_rotation_degrees + randf(), 0.5)
	tween.tween_property(self, "global_scale", global_scale * 0.9, 0.5)
