extends Node2D


@export var host: Player


var shake_intensity: float = 0.0
var active_shake_dur: float = 0.0

var shake_decay: float = 5.0

var shake_time: float = 0.0
var shake_time_speed: float = 20.0

var noise: FastNoiseLite = FastNoiseLite.new()


@onready var cam: Camera2D = $Camera
@onready var viewport_rect: Rect2 = get_viewport_rect()

func _ready() -> void:
	host.cam_ctrl = self


func _process(delta: float) -> void:
	if host:
		global_position = host.global_position
		
		var mouse_pos: Vector2 = get_global_mouse_position()
		cam.position.x = lerp(cam.position.x, (mouse_pos.x - host.global_position.x) / (viewport_rect.size.x / 2.0) * 128, 0.8)
		cam.position.y = lerp(cam.position.y, (mouse_pos.y - host.global_position.y) / (viewport_rect.size.y / 2.0) * 128, 0.8)
	
	if not Settings.screenshake:
		return
	
	if active_shake_dur > 0.0:
		shake_time += shake_time_speed * delta
		active_shake_dur -= delta
		
		cam.offset = Vector2(
			noise.get_noise_2d(shake_time, 0) * shake_intensity,
			noise.get_noise_2d(0, shake_time) * shake_intensity
		)
		
		shake_intensity = max(shake_intensity - shake_decay * delta, 0)
	else:
		cam.offset = lerp(cam.offset, Vector2.ZERO, 10.5 * delta)


func screenshake(intensity: int, dur: float) -> void:
	if not Settings.screenshake:
		return
	
	noise.seed = randi()
	noise.frequency = 2.0
	
	shake_intensity = intensity * Settings.screenshake_val
	active_shake_dur = dur * max(Settings.screenshake_val / 2.0, 2.4)
	shake_time = 0.0
