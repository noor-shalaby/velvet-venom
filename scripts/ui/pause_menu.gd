extends CanvasLayer


@onready var tree: SceneTree = get_tree()


func _ready():
	hide()


func _input(event: InputEvent):
	if event.is_action_pressed("pause"):
		visible = !visible
		tree.paused = !tree.paused


func _on_resume_button_pressed():
	hide()
	tree.paused = false
