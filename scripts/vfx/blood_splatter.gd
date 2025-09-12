extends ParticleEffect


const BLOOD_STAIN_SCENE: PackedScene = preload(Constants.FILE_UIDS["blood_stain_scene"])


@onready var game: Node2D = $/root/Game

func _ready() -> void:
	super()
	
	var blood_stain: Sprite2D = BLOOD_STAIN_SCENE.instantiate()
	blood_stain.global_position = global_position - Vector2.from_angle(global_rotation) * randf_range(16, 32)
	blood_stain.scale *= scale
	game.add_child(blood_stain)
