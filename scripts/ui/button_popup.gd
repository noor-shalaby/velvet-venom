extends Buttona


@export var popup: CanvasLayer


func _on_pressed() -> void:
	super()
	
	if popup:
		popup.popup()
