extends Node2D


@export var host: Player


var shake_intensity: float = 0.0
var active_shake_dur: float = 0.0

var shake_decay: float = 5.0

var shake_time: float = 0.0
var shake_time_speed: float = 20.0

var noise = FastNoiseLite.new()


@onready var cam: Camera2D = $Camera

func _ready():
	randomize()


func _physics_process(delta):
	if host:
		global_position = host.global_position
		host.cam_ctrl = self
		
		var mouse_pos = get_global_mouse_position()
		cam.position.x = (mouse_pos.x - host.global_position.x) / (get_viewport_rect().size.x / 2.0) * 128
		cam.position.y = (mouse_pos.y - host.global_position.y) / (get_viewport_rect().size.y / 2.0) * 128
	
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


func screenshake(intensity: int, dur: float):
	noise.seed = randi()
	noise.frequency = 2.0
	
	shake_intensity = intensity
	active_shake_dur = dur
	shake_time = 0.0
