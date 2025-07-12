extends Camera2D


@export var host: Player


func _physics_process(delta: float):
	if host:
		global_position = host.global_position
		
		var mouse_pos = get_global_mouse_position()
		offset.x = (mouse_pos.x - host.global_position.x) / (get_viewport_rect().size.x / 2.0)
		offset.y = (mouse_pos.y - host.global_position.y) / (get_viewport_rect().size.y / 2.0)
