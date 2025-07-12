extends Button


@export var target_scene: PackedScene


@onready var tree: SceneTree = get_tree()


func _on_pressed():
	tree.change_scene_to_packed(target_scene)
