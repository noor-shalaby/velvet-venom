extends ParticleEffect


var blood_stain_scene = preload("uid://mg1wvhjyn4p6")


@onready var game: Node2D = $/root/Game

func _ready():
	super()
	
	var blood_stain: Sprite2D = blood_stain_scene.instantiate()
	blood_stain.global_position = global_position - Vector2.from_angle(global_rotation) * randf_range(16, 32)
	blood_stain.scale *= scale
	game.add_child(blood_stain)
