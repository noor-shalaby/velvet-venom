extends ZombieNorm


@onready var dash_particles: GPUParticles2D = $DashParticles

func _ready() -> void:
	super()
	
	dash_particles.texture = sprite.sprite_frames.get_frame_texture("hold", 0)


func set_target(new_target: CharacterBody2D) -> void:
	super(new_target)
	
	if new_target:
		dash_particles.emitting = true
	else:
		dash_particles.emitting = false
