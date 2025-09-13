extends Zombie


var gun: Dictionary[String, Variant] = {
	"name": "gun",
	"dmg": 10,
	"fire_rate": 3.0,
	"multishot": 1,
	"spread": 20.0,
	"recoil": 24.0,
	"knockback_force": 2000.0,
	"puncture": 0,
	"wall_puncture": 0,
	"mag_max": 8,
	"mag": 8,
	"reload_time": 1.16,
	"gunshot_sound_scene": preload(Constants.FILE_UIDS["gunshot_gun_sound_scene"]),
	"reload_start_sound": preload(Constants.FILE_UIDS["reload_start_sound_gun"]),
	"reload_end_sound": preload(Constants.FILE_UIDS["reload_end_sound_gun"])
}
var machinegun: Dictionary[String, Variant] = {
	"name": "machinegun",
	"dmg": 12,
	"fire_rate": 16.0,
	"multishot": 1,
	"spread": 30.0,
	"recoil": 16.0,
	"knockback_force": 2500.0,
	"puncture": 0,
	"wall_puncture": 0,
	"mag_max": 32,
	"mag": 32,
	"reload_time": 1.64,
	"gunshot_sound_scene": preload(Constants.FILE_UIDS["gunshot_machinegun_sound_scene"]),
	"reload_start_sound": preload(Constants.FILE_UIDS["reload_start_sound_machinegun"]),
	"reload_end_sound": preload(Constants.FILE_UIDS["reload_end_sound_machinegun"])
}
var shotgun: Dictionary[String, Variant] = {
	"name": "shotgun",
	"dmg": 15,
	"fire_rate": 2.0,
	"multishot": 8,
	"spread": 40.0,
	"recoil": 128.0,
	"knockback_force": 5000.0,
	"puncture": 1,
	"wall_puncture": 0,
	"mag_max": 4,
	"mag": 4,
	"reload_time": 2.64,
	"gunshot_sound_scene": preload(Constants.FILE_UIDS["gunshot_shotgun_sound_scene"]),
	"reload_start_sound": preload(Constants.FILE_UIDS["reload_start_sound_shotgun"]),
	"reload_end_sound": preload(Constants.FILE_UIDS["reload_end_sound_shotgun"])
}

var weapons: Array[Dictionary] = [
	gun,
	machinegun,
	#shotgun
]

var weapon: Dictionary[String, Variant] = weapons.pick_random()

@export_range(0.0, 1.0, 0.01) var precision: float = 6.0
@export var melee_range: float = 76.0

var can_shoot: bool = true
var open_fire_on_screen: bool = false
@export var open_fire_on_screen_delay_time: float = 1.0
var melee_mode: bool = false

const BULLET_SCENE: PackedScene = preload(Constants.FILE_UIDS["bullet_scene"])
const MUZZLE_FLASH_SCENE: PackedScene = preload(Constants.FILE_UIDS["muzzle_flash_scene"])


@onready var scene_tree: SceneTree = get_tree()
@onready var muzzle: Marker2D = $Muzzle
@onready var fire_delay: Timer = $FireDelay
@onready var reload_timer: Timer = $ReloadTimer
@onready var reload_sound_player: AudioStreamPlayer2D = $ReloadSound
@onready var reload_sound_default_volume_db: float = reload_sound_player.volume_db
@onready var open_fire_on_screen_delay: Timer = $OpenFireOnScreenDelay
@onready var melee_range_area: Area2D = $MeleeRange
@onready var melee_range_shape: CollisionShape2D = $MeleeRange/CollisionShape
@onready var melee_ray: RayCast2D = $MeleeRange/RayCast
const SPRITESHEETS: Array[SpriteFrames] = [
	preload(Constants.FILE_UIDS["zombie_gunner1_spriteframes"]),
	preload(Constants.FILE_UIDS["zombie_gunner2_spriteframes"])
]


func _ready() -> void:
	super()
	
	sprite.sprite_frames = SPRITESHEETS.pick_random()
	sprite.play(weapon["name"])
	weapon["mag"] = weapon["mag_max"]
	fire_delay.wait_time = 1.0 / weapon["fire_rate"]
	reload_timer.wait_time = weapon["reload_time"]
	open_fire_on_screen_delay.wait_time = open_fire_on_screen_delay_time
	melee_range_shape.shape.radius = melee_range
	melee_ray.target_position.x = melee_range - 34


func _physics_process(delta: float) -> void:
	if not is_stunned:
		look_for_target()
		
		if target and eyes_on_target(target) > 1 and not melee_ray.is_colliding() and not melee_mode and open_fire_on_screen and vis_notifier.is_on_screen():
			velocity = Vector2.ZERO
			if sprite.animation != weapon["name"] + "_reload":
				global_rotation = lerp_angle(global_rotation, (target.global_position - global_position).angle(), precision * delta)
			shoot()
		else:
			var next_path_pos: Vector2 = nav_agent.get_next_path_position()
			dir = global_position.direction_to(next_path_pos)
			global_rotation = lerp_angle(global_rotation, (next_path_pos - global_position).angle(), turning_speed * delta)
			velocity = movement_speed * dir
	
	handle_knockback()
	
	move_and_slide()


func set_target(new_target: CharacterBody2D) -> void:
	super(new_target)
	
	if not target and weapon["mag"] < weapon["mag_max"]:
		reload()


func shoot() -> void:
	if can_shoot and weapon["mag"] > 0 and reload_timer.is_stopped() and not is_stunned:
		can_shoot = false
		fire_delay.start()
		weapon["mag"] -= 1
		if weapon["mag"] <= 0:
			reload()
		
		var bullet: Bullet = BULLET_SCENE.instantiate()
		bullet.global_position = muzzle.global_position
		bullet.global_rotation = global_rotation
		game.add_child(bullet)
		
		bullet.dir = Vector2.from_angle(global_rotation)
		bullet.dmg = weapon["dmg"]
		bullet.knockback_force = weapon["knockback_force"]
		bullet.puncture = weapon["puncture"]
		bullet.wall_puncture = weapon["wall_puncture"]
		bullet.shooter = self
		
		if Settings.audio:
			var gunshot_sound: AudioStreamPlayer2D = weapon["gunshot_sound_scene"].instantiate()
			gunshot_sound.global_position = muzzle.global_position
			game.add_child(gunshot_sound)
		
		for shot in range(weapon["multishot"] - 1):
			bullet = BULLET_SCENE.instantiate()
			bullet.global_position = muzzle.global_position
			bullet.global_rotation = global_rotation
			game.add_child(bullet)
			
			bullet.dir = Vector2.from_angle(global_rotation + randf_range(deg_to_rad(-weapon["spread"]/2), deg_to_rad(weapon["spread"]/2))).normalized()
			bullet.dmg = weapon["dmg"]
			bullet.knockback_force = weapon["knockback_force"]
			bullet.puncture = weapon["puncture"]
			bullet.wall_puncture = weapon["wall_puncture"]
			bullet.shooter = self
		
		var muzzle_flash: ParticleEffect = MUZZLE_FLASH_SCENE.instantiate()
		muzzle.add_child(muzzle_flash)
		
		velocity += randf_range(0, weapon["recoil"]) * -dir


func _on_screen_entered() -> void:
	super()
	
	open_fire_on_screen_delay.start()

func _on_screen_exited() -> void:
	super()
	
	open_fire_on_screen = false


func reload() -> void:
	reload_timer.start()
	sprite.play(weapon["name"] + "_reload")
	
	if not Settings.audio:
		return
	reload_sound_player.stream = weapon["reload_start_sound"]
	reload_sound_player.volume_db = reload_sound_default_volume_db * randf_range(-Constants.RANDOFACTO, Constants.RANDOFACTO)
	reload_sound_player.volume_linear *= Settings.audio_val
	reload_sound_player.play()
	await scene_tree.create_timer(weapon["reload_time"] - weapon["reload_end_sound"].get_length() * 0.6).timeout
	if sprite.animation == weapon["name"] + "_reload":
		reload_sound_player.stream = weapon["reload_end_sound"]
		reload_sound_player.volume_db = reload_sound_default_volume_db * randf_range(-Constants.RANDOFACTO, Constants.RANDOFACTO)
		reload_sound_player.volume_linear *= Settings.audio_val
		reload_sound_player.play()


func _on_fire_delay_timeout() -> void:
	can_shoot = true


func _on_reload_timer_timeout() -> void:
	weapon["mag"] = weapon["mag_max"]
	sprite.play(weapon["name"])


func _on_melee_range_body_entered(body: Node2D) -> void:
	if target and body == target and weapon["mag"] <= 0:
		reload_timer.stop()
		melee_mode = true
		sprite.play("hold")


func _on_melee_range_body_exited(body: Node2D) -> void:
	if is_stunned:
		return
	if body == target:
		melee_mode = false
		if weapon["mag"] <= 0:
			reload()
		else:
			sprite.play(weapon["name"])


func stunned(duration: float) -> void:
	super(duration)
	
	reload_timer.stop()
	melee_mode = true
	sprite.play("stand")
	melee_range_area.set_deferred("monitoring", false)

func _on_stun_timer_timeout() -> void:
	super()
	
	sprite.play("hold")


func _on_open_fire_on_screen_delay_timeout() -> void:
	open_fire_on_screen = true


func _on_sprite_animation_changed() -> void:
	if sprite.animation != weapon["name"] + "_reload":
		reload_sound_player.stop()
