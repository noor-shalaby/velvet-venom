class_name PlayerNorm
extends Player


var gun: Dictionary[String, Variant] = {
	"name": "gun",
	"index": 0,
	"damage": 20,
	"fire_rate": 3.0,
	"multishot": 1,
	"spread": 20.0,
	"projectile_speed": 2000.0,
	"recoil": 24.0,
	"knockback_force": 4000.0,
	"puncture": 0,
	"wall_puncture": 0,
	"mag_max": 8,
	"mag": 8,
	"reload_time": 1.16,
	"gunshot_sound_scene": preload(Constants.FILE_UIDS.gunshot_gun_sound_scene),
	"reload_start_sound": preload(Constants.FILE_UIDS.reload_start_sound_gun),
	"reload_end_sound": preload(Constants.FILE_UIDS.reload_end_sound_gun)
}
var machinegun: Dictionary[String, Variant] = {
	"name": "machinegun",
	"index": 1,
	"damage": 24,
	"fire_rate": 16.0,
	"multishot": 1,
	"spread": 30.0,
	"projectile_speed": 3000.0,
	"recoil": 16.0,
	"knockback_force": 5000.0,
	"puncture": 0,
	"wall_puncture": 0,
	"mag_max": 32,
	"mag": 32,
	"reload_time": 1.64,
	"gunshot_sound_scene": preload(Constants.FILE_UIDS.gunshot_machinegun_sound_scene),
	"reload_start_sound": preload(Constants.FILE_UIDS.reload_start_sound_machinegun),
	"reload_end_sound": preload(Constants.FILE_UIDS.reload_end_sound_machinegun)
}
var shotgun: Dictionary[String, Variant] = {
	"name": "shotgun",
	"index": 2,
	"damage": 40,
	"fire_rate": 2.0,
	"multishot": 8,
	"spread": 40.0,
	"projectile_speed": 4000.0,
	"recoil": 128.0,
	"knockback_force": 10000.0,
	"puncture": 1,
	"wall_puncture": 0,
	"mag_max": 4,
	"mag": 4,
	"reload_time": 2.64,
	"gunshot_sound_scene": preload(Constants.FILE_UIDS.gunshot_shotgun_sound_scene),
	"reload_start_sound": preload(Constants.FILE_UIDS.reload_start_sound_shotgun),
	"reload_end_sound": preload(Constants.FILE_UIDS.reload_end_sound_shotgun)
}

var weapons: Dictionary[String, Dictionary] = {
	"gun": gun,
	"machinegun": machinegun,
	"shotgun": shotgun
}

var held_weapons: Array[Dictionary] = [
	gun,
	{},
	{}
]

var held_weapon: Dictionary[String, Variant]:
	set = set_held_weapon
func set_held_weapon(new_held_weapon: Dictionary[String, Variant]) -> void:
	held_weapon = new_held_weapon
	EventBus.emit_signal("player_weapon_changed", held_weapon.name)
	EventBus.emit_signal("player_mag_changed", held_weapon.mag)
	sprite.play(held_weapon.name)
	reload_timer.stop()
	if held_weapon.mag <= 0:
		reload()
var target_weapon_i: int

var default_weapon_i: int = 0

var blood_tween: Tween
var active_blood_tweens: Array = []
var blood_pool: Area2D
var is_sucking: bool = false

const BULLET_SCENE: PackedScene = preload(Constants.FILE_UIDS.bullet_scene)
const MUZZLE_FLASH_SCENE: PackedScene = preload(Constants.FILE_UIDS.muzzle_flash_scene)


@onready var scene_tree: SceneTree = get_tree()
@onready var reload_timer: Timer = $ReloadTimer
@onready var reload_sound_player: AudioStreamPlayer2D = $ReloadSound
@onready var reload_sound_default_volume_db: float = reload_sound_player.volume_db

func _ready() -> void:
	super()
	
	held_weapon = held_weapons[default_weapon_i]
	target_weapon_i = held_weapon.index
	held_weapon.mag = held_weapon.mag_max
	
	EventBus.emit_signal("player_weapon_changed", held_weapon.name)
	EventBus.emit_signal("player_mag_changed", held_weapon.mag)



func _physics_process(delta: float) -> void:
	super(delta)
	
	if Input.is_action_pressed("fire") and can_shoot and held_weapon.mag > 0:
		can_shoot = false
		fire_delay.start(1.0/held_weapon.fire_rate)
		
		reload_timer.stop()
		sprite.play(held_weapon.name)
		
		held_weapon.mag -= 1
		EventBus.emit_signal("player_mag_changed", held_weapon.mag)
		if held_weapon.mag <= 0:
			reload()
		
		
		var bullet: Bullet = BULLET_SCENE.instantiate()
		bullet.global_position = muzzle.global_position
		bullet.global_rotation = global_rotation
		game.add_child(bullet)
		
		bullet.dir = dir
		bullet.damage = held_weapon.damage
		bullet.speed = held_weapon.projectile_speed
		bullet.knockback_force = held_weapon.knockback_force
		bullet.puncture = held_weapon.puncture
		bullet.wall_puncture = held_weapon.wall_puncture
		bullet.shooter = self
		
		if Settings.audio:
			var gunshot_sound: AudioStreamPlayer2D = held_weapon.gunshot_sound_scene.instantiate()
			gunshot_sound.global_position = muzzle.global_position
			game.add_child(gunshot_sound)
		
		if cam_ctrl and Settings.screenshake:
			cam_ctrl.screenshake(max(1.64, held_weapon.multishot / 1.16), 0.1)
		for shot in range(held_weapon.multishot - 1):
			bullet = BULLET_SCENE.instantiate()
			bullet.global_position = muzzle.global_position
			bullet.global_rotation = global_rotation
			game.add_child(bullet)
			
			bullet.dir = Vector2.from_angle(dir.angle() + randf_range(deg_to_rad(-held_weapon.spread/2), deg_to_rad(held_weapon.spread/2))).normalized()
			bullet.damage = held_weapon.damage
			bullet.knockback_force = held_weapon.knockback_force
			bullet.puncture = held_weapon.puncture
			bullet.wall_puncture = held_weapon.wall_puncture
			bullet.shooter = self
		
		var muzzle_flash: ParticleEffect = MUZZLE_FLASH_SCENE.instantiate()
		muzzle.add_child(muzzle_flash)
		
		velocity += randf_range(0, held_weapon.recoil) * -dir


func _unhandled_input(event: InputEvent) -> void:
	super(event)
	
	if event.is_action_pressed("scroll_up"):
		target_weapon_i = clamp(target_weapon_i - 1, 0, held_weapons.size() - 1)
		if held_weapons[target_weapon_i]:
			held_weapon = held_weapons[target_weapon_i]
	elif event.is_action_pressed("scroll_down"):
		target_weapon_i = clamp(target_weapon_i + 1, 0, held_weapons.size() - 1)
		if held_weapons[target_weapon_i]:
			held_weapon = held_weapons[target_weapon_i]
	
	if event.is_action_pressed("reload") and held_weapon.mag < held_weapon.mag_max and reload_timer.is_stopped():
		reload()
	
	if event.is_action_pressed("gun") and held_weapon != held_weapons[0] and held_weapons[0]:
		held_weapon = held_weapons[0]
	elif event.is_action_pressed("machinegun") and held_weapon != held_weapons[1] and held_weapons[1]:
		held_weapon = held_weapons[1]
	elif event.is_action_pressed("shotgun") and held_weapon != held_weapons[2] and held_weapons[2]:
		held_weapon = held_weapons[2]


func reload() -> void:
	reload_timer.start(held_weapon.reload_time)
	sprite.play(held_weapon.name + "_reload")
	
	if not Settings.audio:
		return
	reload_sound_player.stream = held_weapon.reload_start_sound
	reload_sound_player.volume_db = reload_sound_default_volume_db * randf_range(-Constants.RANDOFACTO, Constants.RANDOFACTO)
	reload_sound_player.volume_linear *= Settings.audio_val
	reload_sound_player.play()
	await scene_tree.create_timer(held_weapon.reload_time - held_weapon.reload_end_sound.get_length() * 0.6).timeout
	if sprite.animation == held_weapon.name + "_reload":
		reload_sound_player.stream = held_weapon.reload_end_sound
		reload_sound_player.volume_db = reload_sound_default_volume_db * randf_range(-Constants.RANDOFACTO, Constants.RANDOFACTO)
		reload_sound_player.volume_linear *= Settings.audio_val
		reload_sound_player.play()


func _on_reload_timer_timeout() -> void:
	held_weapon.mag = held_weapon.mag_max
	sprite.play(held_weapon.name)
	EventBus.emit_signal("player_mag_changed", held_weapon.mag)


func _on_sprite_animation_changed() -> void:
	if sprite.animation != held_weapon.name + "_reload":
		reload_sound_player.stop()
