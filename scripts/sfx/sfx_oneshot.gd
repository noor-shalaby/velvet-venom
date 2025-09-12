extends AudioStreamPlayer


func _ready() -> void:
	volume_linear *= Settings.audio_val
	
	finished.connect(queue_free)
