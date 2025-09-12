extends AudioStreamPlayer2D


@export var rando_type: Constants.RANDO_TYPES = Constants.RANDO_TYPES.NORMAL


func _ready() -> void:
	var _rando: float
	match rando_type:
		Constants.RANDO_TYPES.NONE:
			_rando = 0.0
		Constants.RANDO_TYPES.SUBTLE:
			_rando = Constants.RANDOFACTO_SUBTLE
		Constants.RANDO_TYPES.NORMAL:
			_rando = Constants.RANDOFACTO
	volume_db += volume_db * randf_range(-Constants.RANDOFACTO, Constants.RANDOFACTO)
	volume_linear *= Settings.audio_val
	pitch_scale += pitch_scale * randf_range(-Constants.RANDOFACTO, Constants.RANDOFACTO)
	
	finished.connect(queue_free)
