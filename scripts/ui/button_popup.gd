extends Buttona


@export var popup: CanvasLayer


func _on_pressed() -> void:
	if popup:
		popup.popup()
