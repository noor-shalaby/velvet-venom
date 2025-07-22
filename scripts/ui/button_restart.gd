extends Button


@onready var tree: SceneTree = get_tree()


func _on_pressed() -> void:
	tree.reload_current_scene()
	tree.paused = false
