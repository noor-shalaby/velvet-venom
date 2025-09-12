extends Node2D


const BLOOD_STAIN_SCENE: PackedScene = preload(Constants.FILE_UIDS["blood_stain_scene"])


@onready var game: Node2D = $/root/Game
@onready var blood_splatters: Array[Node] = get_children()

func _ready() -> void:
	for blood_splatter in blood_splatters:
		blood_splatter.emitting = true
		
		var blood_stain: Sprite2D = BLOOD_STAIN_SCENE.instantiate()
		blood_stain.global_position = global_position - Vector2.from_angle(blood_splatter.global_rotation) * randf_range(16, 32)
		blood_stain.scale *= scale
		game.add_child(blood_stain)


func _on_blood_splatter_finished() -> void:
	queue_free()
