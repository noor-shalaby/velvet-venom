extends CanvasLayer


@onready var tree: SceneTree = get_tree()


func _ready() -> void:
	hide()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		visible = !visible
		tree.paused = !tree.paused


func _on_resume_button_pressed() -> void:
	hide()
	tree.paused = false
