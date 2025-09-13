class_name Player
extends CharacterBody2D

@export_category("Movement")
@export var movement_speed: float = 350.0
@export var friction: float = 18.0

@export_category("Dash")
@export var dash_speed: float = 1500.0
@export var dash_duration: float = 0.05
@export var dash_invincibility_duration: float = 0.1
@export var dash_cooldown: float = 0.2
@export var dash_slash: bool = true
@export var dash_slash_damage: float = 30.0
@export var dash_stun: bool = true
@export var dash_stun_duration: float = 1.0

@export_category("Stats")
@export var hp_max: float = 100.0
var hp: float = hp_max:
	set = set_hp
func set_hp(new_hp: float) -> void:
	if new_hp < hp:
		blink()
		if cam_ctrl and Settings.screenshake:
			cam_ctrl.screenshake((float(hp - new_hp) / hp_max) * 40, 0.2)
	
	hp = clamp(new_hp, 0, hp_max)
	EventBus.emit_signal("player_hp_changed", hp, hp_max)
	
	if hp <= 0:
		die()

@export_category("Appearance")
@export var blood_color: Color = Color(0.824, 0.098, 0.0)


var dir: Vector2
var input_dir: Vector2

var can_shoot: bool = true

var can_dash: bool = true
var dash_dir: Vector2
var is_dashing: bool = false

var is_knocked_back: bool = false
var knockback_velocity: Vector2

const BLOOD_SPLATTER_DOUBLE_SCENE: PackedScene = preload(Constants.FILE_UIDS["blood_splatter_double_scene"])
const BLOOD_EXPLOSION_SCENE: PackedScene = preload(Constants.FILE_UIDS["blood_explosion_scene"])
const BLOOD_POOL_SCENE: PackedScene = preload(Constants.FILE_UIDS["blood_pool_scene"])
const DEATH_SCREEN_SCENE: PackedScene = preload(Constants.FILE_UIDS["death_screen_scene"])
const WALK_SOUNDS: Array[AudioStreamWAV] = [
	preload(Constants.FILE_UIDS["walk_sound1"]),
	preload(Constants.FILE_UIDS["walk_sound2"]),
	preload(Constants.FILE_UIDS["walk_sound3"]),
	preload(Constants.FILE_UIDS["walk_sound4"]),
	preload(Constants.FILE_UIDS["walk_sound5"])
]
const DASH_SOUNDS: Array[AudioStreamWAV] = [
	preload(Constants.FILE_UIDS["dash_sound1"]),
	preload(Constants.FILE_UIDS["dash_sound2"]),
	preload(Constants.FILE_UIDS["dash_sound3"])
]
const DASH_SLASH_SOUNDS: Array[AudioStreamWAV] = [
	preload(Constants.FILE_UIDS["dash_slash_sound1"]),
	preload(Constants.FILE_UIDS["dash_slash_sound2"]),
	preload(Constants.FILE_UIDS["dash_slash_sound3"]),
	preload(Constants.FILE_UIDS["dash_slash_sound4"])
]
const DEATH_SOUND_SCENE: PackedScene = preload(Constants.FILE_UIDS["player_death_sound_scene"])
const DEATH_SOUNDS: Array[AudioStreamWAV] = [
	preload(Constants.FILE_UIDS["player_death_sounds"][0]),
	preload(Constants.FILE_UIDS["player_death_sounds"][1])
]

var cam_ctrl: Node2D


@onready var game: Node2D = $/root/Game
@onready var sprite := $Sprite
@onready var hurtbox: Area2D = $Hurtbox
@onready var muzzle: Marker2D = $Muzzle
@onready var fire_delay: Timer = $FireDelay
@onready var walk_sound_player: AudioStreamPlayer2D = $WalkSound
@onready var walk_sound_default_volume_db: float = walk_sound_player.volume_db
@onready var walk_sound_default_pitch_scale: float = walk_sound_player.pitch_scale

@onready var dash_hitbox: Area2D = $DashHitbox
@onready var dash_duration_timer: Timer = $DashDuration
@onready var dash_invincibility_duration_timer: Timer = $DashInvincibilityDuration
@onready var dash_cooldown_timer: Timer = $DashCooldown
@onready var dash_particles: GPUParticles2D = $DashParticles
@onready var dash_sound_player: AudioStreamPlayer2D = $DashSound
@onready var dash_sound_default_volume_db: float = dash_sound_player.volume_db
@onready var dash_sound_default_pitch_scale: float = dash_sound_player.pitch_scale
@onready var dash_slash_sound_player: AudioStreamPlayer2D = $DashSlashSound
@onready var dash_slash_sound_default_volume_db: float = dash_slash_sound_player.volume_db
@onready var dash_slash_sound_default_pitch_scale: float = dash_slash_sound_player.pitch_scale

func _ready() -> void:
	EventBus.player = self
	EventBus.emit_signal("player_class_changed", name)
	EventBus.emit_signal("player_hp_changed", hp, hp_max)



func _physics_process(delta: float) -> void:
	look_at(get_global_mouse_position())
	dir = global_position.direction_to(get_global_mouse_position())
	
	input_dir = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down")).normalized()
	
	if not is_dashing:
		velocity = movement_speed * input_dir
		velocity = lerp(get_real_velocity(), velocity, friction * delta)
	
	if is_dashing:
		velocity = dash_speed * dash_dir
		dash_particles.emitting = true
		dash_particles.scale = input_dir
	
	if is_knocked_back:
		velocity += knockback_velocity
		velocity = lerp(get_real_velocity(), velocity, friction * delta)
		is_knocked_back = false
	
	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if (event.is_action_pressed("up") or event.is_action_pressed("down") or event.is_action_pressed("right") or event.is_action_pressed("left")) and not walk_sound_player.playing and not is_dashing and Settings.audio:
		play_walk_sound()
	
	if event.is_action_pressed("dash") and can_dash and not is_dashing:
		dash()



func dash() -> void:
	can_dash = false
	is_dashing = true
	if dash_slash:
		dash_hitbox.set_deferred("monitoring", true)
	
	hurtbox.set_deferred("monitorable", false)
	set_collision_mask_value(5, false)
	
	dash_duration_timer.start(dash_duration)
	dash_invincibility_duration_timer.start(dash_invincibility_duration)
	dash_cooldown_timer.start(dash_cooldown)
	
	if Settings.audio:
		dash_sound_player.stream = DASH_SOUNDS.pick_random()
		dash_sound_player.volume_db = dash_sound_default_volume_db + dash_sound_default_volume_db * randf_range(-Constants.RANDOFACTO, Constants.RANDOFACTO)
		dash_sound_player.volume_linear *= Settings.audio_val
		dash_sound_player.pitch_scale = dash_sound_default_pitch_scale + dash_sound_default_pitch_scale * randf_range(-Constants.RANDOFACTO, Constants.RANDOFACTO)
		dash_sound_player.play()
	
	dash_dir = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down")).normalized()
	if dash_dir == Vector2.ZERO:
		dash_dir = global_position.direction_to(get_global_mouse_position())


func knockback(knockback_force: Vector2) -> void:
	is_knocked_back = true
	knockback_velocity = knockback_force


func die() -> void:
	var blood_explosion: ParticleEffect = BLOOD_EXPLOSION_SCENE.instantiate()
	blood_explosion.global_position = global_position
	game.add_child(blood_explosion)
	
	var blood_pool: Area2D = BLOOD_POOL_SCENE.instantiate()
	blood_pool.global_position = global_position
	game.call_deferred("add_child", blood_pool)
	
	if Settings.audio:
		var death_sound: AudioStreamPlayer2D = DEATH_SOUND_SCENE.instantiate()
		death_sound.global_position = global_position
		game.add_child(death_sound)
	
	var death_screen: CanvasLayer = DEATH_SCREEN_SCENE.instantiate()
	game.add_child(death_screen)
	
	queue_free()


func play_walk_sound() -> void:
	if not Settings.audio:
		return
	
	walk_sound_player.stream = WALK_SOUNDS.pick_random()
	walk_sound_player.volume_db = walk_sound_default_volume_db + walk_sound_default_volume_db * randf_range(-Constants.RANDOFACTO_SUBTLE, Constants.RANDOFACTO_SUBTLE)
	walk_sound_player.volume_linear *= Settings.audio_val
	walk_sound_player.pitch_scale = walk_sound_default_pitch_scale + walk_sound_default_pitch_scale * randf_range(-Constants.RANDOFACTO_SUBTLE, Constants.RANDOFACTO_SUBTLE)
	walk_sound_player.play()


func blink() -> void:
	create_tween().tween_method(set_blink_shader_intensity, 1.32, 0.0, 0.2)

func set_blink_shader_intensity(new_value: float) -> void:
	sprite.material.set_shader_parameter("blink_intensity", new_value)


func _on_fire_delay_timeout() -> void:
	can_shoot = true


func _on_dash_cooldown_timeout() -> void:
	can_dash = true

func _on_dash_invincibility_duration_timeout() -> void:
	hurtbox.set_deferred("monitorable", true)
	set_collision_mask_value(5, true)
	dash_hitbox.set_deferred("monitoring", false)

func _on_dash_duration_timeout() -> void:
	is_dashing = false

func _on_dash_hitbox_body_entered(body: Zombie) -> void:
	if dash_slash:
		body.hp -= dash_slash_damage
		if cam_ctrl and Settings.screenshake:
			cam_ctrl.screenshake(16, 0.08)
		
		var blood_splatter_double: Node2D = BLOOD_SPLATTER_DOUBLE_SCENE.instantiate()
		blood_splatter_double.global_position = body.global_position
		blood_splatter_double.global_rotation = dash_dir.angle()
		blood_splatter_double.global_scale = body.global_scale
		game.add_child(blood_splatter_double)
		
		
		if dash_stun:
			body.stunned(dash_stun_duration)
		
		if not dash_slash_sound_player.playing and Settings.audio:
			dash_slash_sound_player.stream = DASH_SLASH_SOUNDS.pick_random()
			dash_slash_sound_player.volume_db = dash_slash_sound_default_volume_db + dash_slash_sound_default_volume_db * randf_range(-Constants.RANDOFACTO, Constants.RANDOFACTO)
			dash_slash_sound_player.volume_linear *= Settings.audio_val
			dash_slash_sound_player.pitch_scale = dash_slash_sound_default_pitch_scale + dash_slash_sound_default_pitch_scale * randf_range(-Constants.RANDOFACTO, Constants.RANDOFACTO)
			dash_slash_sound_player.play()


func _on_walk_sound_finished() -> void:
	if not Settings.audio:
		return
	
	if (Input.is_action_pressed("up") or Input.is_action_pressed("down") or Input.is_action_pressed("right") or Input.is_action_pressed("left")) and not is_dashing:
		play_walk_sound()
