class_name ParticleEffect
extends CPUParticles2D


func _ready() -> void:
	emitting = true
	finished.connect(queue_free)


func _on_finished() -> void:
	queue_free()
