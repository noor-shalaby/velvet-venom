class_name PlayerVamp
extends Player


var fire_empty: Dictionary[String, Variant] = {
	"dmg": 20,
	"fire_rate": 3.0,
	"multishot": 1,
	"spread": 20.0,
	"recoil": 24.0,
	"knockback_force": 4000,
	"puncture": 0,
	"wall_puncture": 0,
	"gunshot_sound_scene": preload(Constants.FILE_UIDS["gunshot_gun_sound_scene"])
}
var fire: Dictionary[String, Variant] = {
	"dmg": 24,
	"fire_rate": 16.0,
	"multishot": 1,
	"spread": 30.0,
	"recoil": 16.0,
	"knockback_force": 5000,
	"puncture": 0,
	"wall_puncture": 0,
	"gunshot_sound_scene": preload(Constants.FILE_UIDS["gunshot_machinegun_sound_scene"])
}
var fire_alt: Dictionary[String, Variant] = {
	"dmg": 40,
	"fire_rate": 2.0,
	"multishot": 8,
	"spread": 40.0,
	"recoil": 128.0,
	"knockback_force": 10000,
	"puncture": 1,
	"wall_puncture": 0,
	"gunshot_sound_scene": preload(Constants.FILE_UIDS["gunshot_shotgun_sound_scene"])
}


func set_hp(new_hp: float) -> void:
	super(new_hp)
	
	if new_hp >= hp_max:
		stop_sucking()
		if blood < blood_max and not is_sucking and Input.is_action_pressed("suck"):
			start_sucking(blood_pool, "blood")


@export var blood_max: float = 128.0
@export var blood: float = 96.0:
	set = set_blood
func set_blood(new_value: float) -> void:
	blood = clamp(new_value, 0, blood_max)
	EventBus.emit_signal("player_blood_changed", blood, blood_max)
	
	if new_value >= blood_max:
		stop_sucking()
		if hp < hp_max and not is_sucking and Input.is_action_pressed("reload"):
			start_sucking(blood_pool)

var blood_tween: Tween
var active_blood_tweens: Array[Tween] = []
var blood_pool: BloodPool
var is_sucking: bool = false
var suck_sound_last_playback_position: float = 0.0


const BLOODSHOT_SCENE: PackedScene = preload(Constants.FILE_UIDS["bloodshot_scene"])
const BLOOD_SPLASH_SCENE: PackedScene = preload(Constants.FILE_UIDS["blood_splash_scene"])


@onready var scene_tree: SceneTree = get_tree()
@onready var arm_left: Sprite2D = $ArmLeft
@onready var arm_right: Sprite2D = $ArmRight
@onready var blood_sucker: Area2D = $BloodSucker
@onready var suction_point: Marker2D = $SuctionPoint
@onready var suck_sound_player: AudioStreamPlayer2D = $SuckSound
@onready var suck_sound_default_volume_db: float = suck_sound_player.volume_db
@onready var suck_sound_default_pitch_scale: float = suck_sound_player.pitch_scale

func _ready() -> void:
	super()
	
	arm_right.hide()
	arm_left.hide()
	
	EventBus.emit_signal("player_blood_changed", blood, blood_max)



func _physics_process(delta: float) -> void:
	super(delta)
	
	if (Input.is_action_pressed("fire") or Input.is_action_pressed("fire_alt")) and can_shoot:
		var wep: Dictionary
		if Input.is_action_pressed("fire") and blood >= fire["multishot"]:
			wep = fire
			blood -= fire["multishot"]
		elif Input.is_action_pressed("fire_alt") and blood >= fire_alt["multishot"]:
			wep = fire_alt
			blood -= fire_alt["multishot"]
		elif Input.is_action_pressed("fire") or Input.is_action_pressed("fire_alt"):
			wep = fire_empty
		
		can_shoot = false
		fire_delay.start(1.0/wep["fire_rate"])
		
		arm_right.show()
		
		
		var bloodshot: Bullet = BLOODSHOT_SCENE.instantiate()
		bloodshot.global_position = muzzle.global_position
		bloodshot.global_rotation = global_rotation
		game.add_child(bloodshot)
		
		bloodshot.dir = dir
		bloodshot.dmg = wep["dmg"]
		bloodshot.knockback_force = wep["knockback_force"]
		bloodshot.puncture = wep["puncture"]
		bloodshot.wall_puncture = wep["wall_puncture"]
		bloodshot.shooter = self
		
		if Settings.audio:
			var gunshot_sound: AudioStreamPlayer2D = wep["gunshot_sound_scene"].instantiate()
			gunshot_sound.global_position = muzzle.global_position
			game.add_child(gunshot_sound)
		
		if cam_ctrl and Settings.screenshake:
			cam_ctrl.screenshake(max(1.64, wep["multishot"] / 1.16), 0.1)
		for shot in range(wep["multishot"] - 1):
			bloodshot = BLOODSHOT_SCENE.instantiate()
			bloodshot.global_position = muzzle.global_position
			bloodshot.global_rotation = global_rotation
			game.add_child(bloodshot)
			
			bloodshot.dir = Vector2.from_angle(dir.angle() + randf_range(deg_to_rad(-wep["spread"]/2), deg_to_rad(wep["spread"]/2))).normalized()
			bloodshot.dmg = wep["dmg"]
			bloodshot.knockback_force = wep["knockback_force"]
			bloodshot.puncture = wep["puncture"]
			bloodshot.wall_puncture = wep["wall_puncture"]
			bloodshot.shooter = self
		
		var blood_splash: ParticleEffect = BLOOD_SPLASH_SCENE.instantiate()
		muzzle.add_child(blood_splash)
		
		velocity += randf_range(0, wep["recoil"]) * -dir
	
	if Input.is_action_just_released("fire") or Input.is_action_just_released("fire_alt"):
		arm_right.hide()
	
	if Input.is_action_pressed("reload") and (blood < blood_max or hp < hp_max) and not is_sucking:
		blood_pool = blood_sucker.get_overlapping_areas().pop_front()
		if blood_pool:
			start_sucking(blood_pool, "blood")
		else:
			blood_pool = blood_sucker.get_overlapping_areas().pop_front()
	elif Input.is_action_pressed("suck") and (hp < hp_max or blood < blood_max) and not is_sucking:
		blood_pool = blood_sucker.get_overlapping_areas().pop_front()
		if blood_pool:
			start_sucking(blood_pool)
		else:
			blood_pool = blood_sucker.get_overlapping_areas().pop_front()
	
	if Input.is_action_just_released("suck") or Input.is_action_just_released("reload"):
		stop_sucking()


func _unhandled_input(event: InputEvent) -> void:
	super(event)


func dash() -> void:
	super()
	
	outline_on()

func _on_dash_duration_timeout() -> void:
	super()
	
	outline_off()



func start_sucking(_blood_pool: BloodPool, resource: String = "hp") -> void:
	stop_sucking()
	
	arm_left.show()
	is_sucking = true
	
	if Settings.audio:
		suck_sound_player.volume_db = suck_sound_default_volume_db + suck_sound_default_volume_db * randf_range(-Constants.RANDOFACTO, Constants.RANDOFACTO)
		suck_sound_player.pitch_scale = suck_sound_default_pitch_scale + suck_sound_default_pitch_scale * randf_range(-Constants.RANDOFACTO, Constants.RANDOFACTO)
		suck_sound_player.volume_linear *= Settings.audio_val
		suck_sound_player.play(suck_sound_last_playback_position)
	
	if _blood_pool.tween:
		_blood_pool.tween.kill()
	
	blood_tween = create_tween().set_parallel(true)
	active_blood_tweens.append(blood_tween)
	blood_tween.tween_property(_blood_pool.sprite, "global_scale", Vector2.ZERO, _blood_pool.sprite.global_scale.x * 2.0)
	blood_tween.tween_property(_blood_pool, "global_rotation_degrees", _blood_pool.global_rotation_degrees + (_blood_pool.sprite.global_scale.x * 16.0), _blood_pool.sprite.global_scale.x * 2.0)
	
	if resource == "hp" and hp >= hp_max:
		resource = "blood"
	elif resource == "blood" and blood >= blood_max:
		resource = "hp"
	
	match resource:
		"hp":
			blood_tween.tween_property(self, "hp", hp + _blood_pool.sprite.global_scale.x * 50, _blood_pool.sprite.global_scale.x * 2.0)
		"blood":
			blood_tween.tween_property(self, "blood", blood + _blood_pool.sprite.global_scale.x * 64, _blood_pool.sprite.global_scale.x * 2.0)
	blood_tween.finished.connect(_blood_pool.queue_free)

func stop_sucking() -> void:
	arm_left.hide()
	is_sucking = false
	
	if suck_sound_player.is_playing():
		suck_sound_last_playback_position = suck_sound_player.get_playback_position()
	suck_sound_player.stop()
	
	for tween in active_blood_tweens:
		if is_instance_valid(tween):
			tween.kill()
	active_blood_tweens.clear()


func outline_on() -> void:
	sprite.material.set_shader_parameter("outline_on", true)
	create_tween().tween_method(set_outline_shader_intensity, sprite.material.get_shader_parameter("line_thickness"), 1.64, 0.2)

func outline_off() -> void:
	var tween: Tween = create_tween()
	tween.tween_method(set_outline_shader_intensity, sprite.material.get_shader_parameter("line_thickness"), 0.0, 0.2)
	await tween.finished
	sprite.material.set_shader_parameter("outline_on", false)

func set_outline_shader_intensity(new_value: float) -> void:
	sprite.material.set_shader_parameter("line_thickness", new_value)


func _on_blood_sucker_area_exited(area: Area2D) -> void:
	if area == blood_pool:
		blood_pool = null
		stop_sucking()


func _on_arm_left_draw() -> void:
	outline_on()

func _on_arm_left_hidden() -> void:
	await scene_tree.create_timer(0.1).timeout
	if not is_sucking:
		outline_off()
