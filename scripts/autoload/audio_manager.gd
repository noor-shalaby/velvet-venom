extends Node


const CLICK_SOUND_SCENE: PackedScene = preload(Constants.FILE_UIDS["click_sound_scene"])
const BACK_SOUND_SCENE: PackedScene = preload(Constants.FILE_UIDS["back_sound_scene"])


var ambient_fade_out: float = 0.3


@onready var scene_tree: SceneTree = get_tree()
@onready var ambient_player: AudioStreamPlayer = $Ambient
@onready var ambient_default_volume_linear: float = ambient_player.volume_linear
@onready var death_fx_player: AudioStreamPlayer = $DeathFX
@onready var death_fx_default_volume_linear: float = death_fx_player.volume_linear
@onready var zombie_alert_vocal_player: AudioStreamPlayer2D = $ZombieAlertVocal
@onready var zombie_alert_vocal_default_volume_db: float = zombie_alert_vocal_player.volume_db


func play_ambient() -> void:
	if not Settings.audio or not Settings.music:
		return
	
	ambient_player.volume_linear = ambient_default_volume_linear * Settings.audio_val * Settings.music_val
	ambient_player.play()

func stop_ambient() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(ambient_player, "volume_linear", 0.0, ambient_fade_out)
	await tween.finished
	ambient_player.stop()


func play_death() -> void:
	if not Settings.audio:
		return
	
	death_fx_player.volume_linear = death_fx_default_volume_linear * Settings.audio_val
	death_fx_player.play()


func play_zombie_alert_vocal(from_position: Vector2, scale: float) -> void:
	if not Settings.audio or zombie_alert_vocal_player.playing:
		return
	
	zombie_alert_vocal_player.stream = Constants.ZOMBIE_ALERT_VOCALS.pick_random()
	zombie_alert_vocal_player.global_position = from_position
	zombie_alert_vocal_player.volume_db = zombie_alert_vocal_default_volume_db + scale
	zombie_alert_vocal_player.volume_linear *= Settings.audio_val
	zombie_alert_vocal_player.play()


func play_oneshot(sfx: PackedScene = CLICK_SOUND_SCENE) -> void:
	if not Settings.audio:
		return
	
	var oneshot_sfx: AudioStreamPlayer = sfx.instantiate()
	add_child(oneshot_sfx)
