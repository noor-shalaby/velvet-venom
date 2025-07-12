extends ZombieNorm


@onready var dash_particles: GPUParticles2D = $DashParticles

func _ready():
	super()
	
	dash_particles.texture = sprite.texture


func set_target(new_target):
	super(new_target)
	
	if new_target:
		dash_particles.emitting = true
	else:
		dash_particles.emitting = false
