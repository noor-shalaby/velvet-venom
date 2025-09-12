extends Buttona


@export var url: String


func _on_pressed() -> void:
	super()
	
	if url:
		OS.shell_open(url)
