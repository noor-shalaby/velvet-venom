extends Node


@onready var scene_tree: SceneTree = get_tree()


var fullscreen: bool = true:
	set = set_fullscreen
func set_fullscreen(_fullscreen: bool) -> void:
	fullscreen = _fullscreen
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

var screenshake: bool = true
var screenshake_val: float = 1.0


var audio: bool = true
var audio_val: float = 1.0:
	set = set_audio_val
func set_audio_val(new_val: float) -> void:
	audio_val = new_val
	AudioManager.ambient_player.volume_linear = AudioManager.ambient_default_volume_linear * audio_val * music_val

var music: bool = true:
	set = set_music
func set_music(_music: bool) -> void:
	music = _music
	if music and scene_tree.current_scene is Control:
		AudioManager.play_ambient()
	else:
		AudioManager.stop_ambient()
var music_val: float = 1.0:
	set = set_music_val
func set_music_val(new_val: float) -> void:
		music_val = new_val
		AudioManager.ambient_player.volume_linear = AudioManager.ambient_default_volume_linear * audio_val * music_val


var gameplay_mouse_capture: bool = true:
	set = set_gameplay_mouse_capture
func set_gameplay_mouse_capture(_gameplay_mouse_capture: bool) -> void:
	gameplay_mouse_capture = _gameplay_mouse_capture
	if gameplay_mouse_capture and scene_tree.current_scene is not Control:
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
