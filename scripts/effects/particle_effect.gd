class_name ParticleEffect
extends CPUParticles2D


func _ready():
	emitting = true
	finished.connect(queue_free)
