extends Buttona


@export var pop_scale: float = 1.6


func _on_pressed() -> void:
	if sfx and Settings.audio:
		if button_pressed:
			AudioManager.play_oneshot(AudioManager.CLICK_SOUND_SCENE)
		else:
			AudioManager.play_oneshot(AudioManager.BACK_SOUND_SCENE)


func pop_animation(dur: float = 0.1) -> void:
	var _tween: Tween = create_tween()
	_tween.tween_property(self, "scale", Vector2.ONE * pop_scale, dur / 2)
	_tween.tween_property(self, "scale", Vector2.ONE, dur)
