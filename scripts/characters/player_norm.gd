class_name PlayerNorm
extends Player


var gun: Dictionary[String, Variant] = {
	"name": "gun",
	"index": 0,
	"dmg": 20,
	"fire_rate": 3.0,
	"multishot": 1,
	"spread": 20.0,
	"recoil": 24.0,
	"knockback_force": 4000,
	"puncture": 0,
	"wall_puncture": 0,
	"mag_max": 8,
	"mag": 8,
	"reload_time": 1.16
}
var machinegun: Dictionary[String, Variant] = {
	"name": "machinegun",
	"index": 1,
	"dmg": 24,
	"fire_rate": 16.0,
	"multishot": 1,
	"spread": 30.0,
	"recoil": 16.0,
	"knockback_force": 5000,
	"puncture": 0,
	"wall_puncture": 0,
	"mag_max": 32,
	"mag": 32,
	"reload_time": 1.64
}
var shotgun: Dictionary[String, Variant] = {
	"name": "shotgun",
	"index": 2,
	"dmg": 40,
	"fire_rate": 2.0,
	"multishot": 8,
	"spread": 40.0,
	"recoil": 128.0,
	"knockback_force": 10000,
	"puncture": 1,
	"wall_puncture": 0,
	"mag_max": 4,
	"mag": 4,
	"reload_time": 2.64
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
	emit_signal("weapon_changed", held_weapon["name"])
	emit_signal("mag_changed", held_weapon["mag"])
	sprite.play(held_weapon["name"])
	reload_timer.stop()
	if held_weapon["mag"] == 0:
		reload()
signal mag_changed
signal weapon_changed
var target_weapon_i: int

var default_weapon_i: int = 0

var blood_tween: Tween
var active_blood_tweens: Array = []
var blood_pool: Area2D
var is_sucking: bool = false

var bullet_scene: PackedScene = preload("uid://durccheqs6y0n")
var muzzle_flash_scene: PackedScene = preload("uid://dtj76lgbo4ydn")


@onready var reload_timer: Timer = $ReloadTimer

func _ready() -> void:
	super()
	
	held_weapon = held_weapons[default_weapon_i]
	target_weapon_i = held_weapon["index"]
	held_weapon["mag"] = held_weapon["mag_max"]
	
	emit_signal("weapon_changed", held_weapon["name"])
	emit_signal("mag_changed", held_weapon["mag"])



func _physics_process(delta: float) -> void:
	super(delta)
	
	if Input.is_action_pressed("fire") and can_shoot and held_weapon["mag"] > 0:
		can_shoot = false
		fire_delay.start(1.0/held_weapon["fire_rate"])
		
		reload_timer.stop()
		sprite.play(held_weapon["name"])
		
		held_weapon["mag"] -= 1
		emit_signal("mag_changed", held_weapon["mag"])
		if held_weapon["mag"] == 0:
			reload()
		
		var bullet: Bullet = bullet_scene.instantiate()
		bullet.global_position = muzzle.global_position
		bullet.global_rotation = global_rotation
		bullet.dir = dir
		bullet.dmg = held_weapon["dmg"]
		bullet.knockback_force = held_weapon["knockback_force"]
		bullet.puncture = held_weapon["puncture"]
		bullet.wall_puncture = held_weapon["wall_puncture"]
		bullet.shooter = self
		game.add_child(bullet)
		cam_ctrl.screenshake(max(1.64, held_weapon["multishot"] / 1.32), 0.1)
		for shot in range(held_weapon["multishot"] - 1):
			bullet = bullet_scene.instantiate()
			bullet.global_position = muzzle.global_position
			bullet.global_rotation = global_rotation
			bullet.dir = Vector2.from_angle(dir.angle() + randf_range(deg_to_rad(-held_weapon["spread"]/2), deg_to_rad(held_weapon["spread"]/2))).normalized()
			bullet.dmg = held_weapon["dmg"]
			bullet.knockback_force = held_weapon["knockback_force"]
			bullet.puncture = held_weapon["puncture"]
			bullet.wall_puncture = held_weapon["wall_puncture"]
			bullet.shooter = self
			game.add_child(bullet)
		
		var muzzle_flash: ParticleEffect = muzzle_flash_scene.instantiate()
		muzzle.add_child(muzzle_flash)
		
		velocity += randf_range(0, held_weapon["recoil"]) * -dir


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
	
	if event.is_action_pressed("reload") and held_weapon["mag"] < held_weapon["mag_max"] and reload_timer.is_stopped():
		reload()
	
	if event.is_action_pressed("gun") and held_weapon != held_weapons[0] and held_weapons[0]:
		held_weapon = held_weapons[0]
	elif event.is_action_pressed("machinegun") and held_weapon != held_weapons[1] and held_weapons[1]:
		held_weapon = held_weapons[1]
	elif event.is_action_pressed("shotgun") and held_weapon != held_weapons[2] and held_weapons[2]:
		held_weapon = held_weapons[2]


func reload() -> void:
	reload_timer.start(held_weapon["reload_time"])
	sprite.play(held_weapon["name"] + "_reload")


func _on_reload_timer_timeout() -> void:
	held_weapon["mag"] = held_weapon["mag_max"]
	sprite.play(held_weapon["name"])
	emit_signal("mag_changed", held_weapon["mag"])


func _on_dash_cooldown_timeout() -> void:
	can_dash = true

func _on_dash_duration_timeout() -> void:
	is_dashing = false
	hitbox.set_deferred("monitorable", true)
