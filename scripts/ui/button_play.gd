extends Button


@export var target_scene_path: String


@onready var tree: SceneTree = get_tree()


func _on_pressed():
	if target_scene_path != "":
		tree.change_scene_to_file(target_scene_path)
		tree.paused = false
