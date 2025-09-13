extends HSlider


@export var drag_speed: float = 2.0


func _process(delta: float) -> void:
	if not has_focus():
		return
	
	var input_dir_x: float = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	if input_dir_x == 0.0:
		return
	
	value += drag_speed * input_dir_x * delta
