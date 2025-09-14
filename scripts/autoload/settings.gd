extends Node


const FILE_NAME: String = "settings.res"


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


const DEFAULTS: Dictionary[String, Variant] = {
	"audio": true,
	"audio_val": 1.0,
	"fullscreen": true,
	"gameplay_mouse_capture": true,
	"music": true,
	"music_val": 1.0,
	"screenshake": true,
	"screenshake_val": 1.0
}


func _ready() -> void:
	load_settings()


func save_settings() -> void:
	var data: SettingsData = SettingsData.new()
	data.audio = audio
	data.audio_val = audio_val
	data.fullscreen = fullscreen
	data.gameplay_mouse_capture = gameplay_mouse_capture
	data.music = music
	data.music_val = music_val
	data.screenshake = screenshake
	data.screenshake_val = screenshake_val
	ResourceSaver.save(data, Constants.SAVE_PATH + FILE_NAME)

func load_settings() -> void:
	if not ResourceLoader.exists(Constants.SAVE_PATH + FILE_NAME):
		return
	
	var data: SettingsData = ResourceLoader.load(Constants.SAVE_PATH + FILE_NAME)
	audio = data.audio
	audio_val = data.audio_val
	fullscreen = data.fullscreen
	gameplay_mouse_capture = data.gameplay_mouse_capture
	music = data.music
	music_val = data.music_val
	screenshake = data.screenshake
	screenshake_val = data.screenshake_val

func reset_settings() -> void:
	if audio != DEFAULTS.audio:
		audio = DEFAULTS.audio
	audio_val = DEFAULTS.audio_val
	fullscreen = DEFAULTS.fullscreen
	gameplay_mouse_capture = DEFAULTS.gameplay_mouse_capture
	if music != DEFAULTS.music:
		music = DEFAULTS.music
	music_val = DEFAULTS.music_val
	screenshake = DEFAULTS.screenshake
	screenshake_val = DEFAULTS.screenshake_val
	save_settings()
