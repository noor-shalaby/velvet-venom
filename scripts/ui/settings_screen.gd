extends Screen


@onready var fullscreen_check: Buttona = %FullscreenCheck
@onready var screenshake_check: Buttona = %ScreenshakeCheck
@onready var screenshake_slider: HSlider = %ScreenshakeSlider

@onready var audio_check: Buttona = %AudioCheck
@onready var audio_slider: HSlider = %AudioSlider
@onready var music_check: Buttona = %MusicCheck
@onready var music_slider: HSlider = %MusicSlider

@onready var gameplay_mouse_capture_check: Buttona = %GameplayMouseCaptureCheck


func _ready() -> void:
	fullscreen_check.button_pressed = Settings.fullscreen
	screenshake_check.button_pressed = Settings.screenshake
	screenshake_slider.value = Settings.screenshake_val
	
	audio_check.button_pressed = Settings.audio
	audio_slider.value = Settings.audio_val
	music_check.button_pressed = Settings.music
	music_slider.value = Settings.music_val
	
	gameplay_mouse_capture_check.button_pressed = Settings.gameplay_mouse_capture


func _on_fullscreen_check_pressed() -> void:
	Settings.fullscreen = fullscreen_check.button_pressed
	Settings.save_settings()

func _on_screenshake_check_pressed() -> void:
	Settings.screenshake = screenshake_check.button_pressed
	Settings.save_settings()


func _on_audio_check_pressed() -> void:
	Settings.audio = audio_check.button_pressed
	Settings.save_settings()

func _on_music_check_pressed() -> void:
	Settings.music = music_check.button_pressed
	Settings.save_settings()


func _on_gameplay_mouse_capture_check_pressed() -> void:
	Settings.gameplay_mouse_capture = gameplay_mouse_capture_check.button_pressed
	Settings.save_settings()


func _on_screenshake_slider_drag_ended(value_changed: bool) -> void:
	if not value_changed:
		return
	
	Settings.screenshake_val = screenshake_slider.value
	Settings.save_settings()


func _on_audio_slider_value_changed(value: float) -> void:
	Settings.audio_val = audio_slider.value
	Settings.save_settings()

func _on_music_slider_value_changed(value: float) -> void:
	Settings.music_val = music_slider.value
	Settings.save_settings()


func _on_reset_button_pressed() -> void:
	Settings.reset_settings()
	if audio_check.button_pressed != Settings.DEFAULTS.audio:
		audio_check.button_pressed = Settings.DEFAULTS.audio
	audio_slider.value = Settings.DEFAULTS.audio_val
	fullscreen_check.button_pressed = Settings.DEFAULTS.fullscreen
	gameplay_mouse_capture_check.button_pressed = Settings.DEFAULTS.gameplay_mouse_capture
	if music_check.button_pressed != Settings.DEFAULTS.music:
		music_check.button_pressed = Settings.DEFAULTS.music
	music_slider.value = Settings.DEFAULTS.music_val
	screenshake_check.button_pressed = Settings.DEFAULTS.screenshake
	screenshake_slider.value = Settings.DEFAULTS.screenshake_val
