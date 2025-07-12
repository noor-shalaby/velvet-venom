class_name Player
extends CharacterBody2D

@export_category("Movement")
@export var movement_speed := 350
@export var friction := 0.3

@export_category("Dash")
@export var dash_speed := 1300
@export var dash_duration := 0.05
@export var dash_cooldown := 0.2

@export_category("Stats")
@export var is_vamp := true
@export var hp_max := 100.0
var hp := hp_max:
	set = set_hp
func set_hp(new_hp):
	if new_hp < hp:
		blink()
	elif new_hp >= hp_max:
		stop_sucking()
	
	hp = clamp(new_hp, 0, hp_max)
	emit_signal("hp_changed", hp, hp_max)
	
	if hp <= 0:
		die()
signal hp_changed
signal dead


var gun = {
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
var machinegun = {
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
var shotgun = {
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

var weapons = {
	"gun": gun,
	"machinegun": machinegun,
	"shotgun": shotgun
}

var held_weapons = [
	gun,
	null,
	null
]

var held_weapon:
	set = set_held_weapon
func set_held_weapon(new_held_weapon):
	held_weapon = new_held_weapon
	emit_signal("weapon_changed", held_weapon["name"])
	emit_signal("mag_changed", held_weapon["mag"])
	animated_sprite.play(held_weapon["name"])
	reload_timer.stop()
	if held_weapon["mag"] == 0:
		reload()
signal mag_changed
signal weapon_changed
var target_weapon_i: int

var default_weapon = 0
var can_shoot = true


var can_dash := true
var dash_dir: Vector2
var is_dashing := false

var is_knocked_back = false
var knockback_velocity: Vector2

var blood_tween: Tween
var active_blood_tweens = []
var blood_pool: Area2D
var is_sucking: bool = false

var bullet_scene = preload("uid://durccheqs6y0n")
var muzzle_flash_scene = preload("uid://dtj76lgbo4ydn")
var blood_explosion_scene = preload("uid://cs6dxwtk5651p")
var blood_pool_scene = preload("uid://1twhq540r50")
var death_screen_scene = preload("uid://bomjpnrcspvgr")



@onready var tree: SceneTree = get_tree()
@onready var game: Node2D = $/root/Game
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite
@onready var hitbox: Area2D = $Hitbox
@onready var blood_sucker: Area2D = $BloodSucker
@onready var muzzle: Marker2D = $Muzzle
@onready var fire_delay: Timer = $FireDelay
@onready var reload_timer: Timer = $ReloadTimer
@onready var dash_duration_timer: Timer = $DashDuration
@onready var dash_cooldown_timer: Timer = $DashCooldown
@onready var dash_particles: GPUParticles2D = $DashParticles

func _ready():
	held_weapon = held_weapons[default_weapon]
	target_weapon_i = held_weapon["index"]
	held_weapon["mag"] = held_weapon["mag_max"]
	
	emit_signal("hp_changed", hp, hp_max)
	emit_signal("weapon_changed", held_weapon["name"])
	emit_signal("mag_changed", held_weapon["mag"])



func _physics_process(delta):
	look_at(get_global_mouse_position())
	var dir = global_position.direction_to(get_global_mouse_position())
	
	var input_dir = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down")).normalized()
	
	if not is_dashing:
		velocity = movement_speed * input_dir
		velocity = lerp(get_real_velocity(), velocity, friction)
	
	if is_dashing:
		velocity = dash_speed * dash_dir
		dash_particles.emitting = true
		dash_particles.scale = input_dir
	
	if Input.is_action_pressed("shoot") and can_shoot and held_weapon["mag"] > 0:
		can_shoot = false
		fire_delay.start(1.0/held_weapon["fire_rate"])
		
		reload_timer.stop()
		animated_sprite.play(held_weapon["name"])
		
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
		
		var muzzle_flash = muzzle_flash_scene.instantiate()
		muzzle.add_child(muzzle_flash)
		
		velocity += randf_range(0, held_weapon["recoil"]) * -dir
	
	if Input.is_action_pressed("suck") and is_vamp and hp < hp_max and not is_sucking:
		blood_pool = blood_sucker.get_overlapping_areas().pop_front()
		if blood_pool:
			start_sucking(blood_pool)
		else:
			blood_pool = blood_sucker.get_overlapping_areas().pop_front()
	if Input.is_action_just_released("suck"):
		stop_sucking()
	
	if is_knocked_back:
		velocity += knockback_velocity
		velocity = lerp(get_real_velocity(), velocity, friction)
		is_knocked_back = false
	
	move_and_slide()


func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("dash") and can_dash and not is_dashing:
		dash()
	
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


func start_sucking(_blood_pool: Area2D):
	is_sucking = true
	reload_timer.stop()
	animated_sprite.play(held_weapon["name"])
	if is_instance_valid(blood_tween):
		blood_tween.kill()
	blood_tween = create_tween().set_parallel(true)
	active_blood_tweens.append(blood_tween)
	blood_tween.tween_property(_blood_pool.sprite, "global_scale", Vector2.ZERO, _blood_pool.sprite.global_scale.x * 2.0)
	blood_tween.tween_property(self, "hp", hp + _blood_pool.scale.x * 50.0, _blood_pool.sprite.global_scale.x * 2.0)
	blood_tween.finished.connect(_blood_pool.queue_free)

func stop_sucking():
	is_sucking = false
	for tween in active_blood_tweens:
		if is_instance_valid(tween):
			tween.kill()
	active_blood_tweens.clear()



func dash():
	can_dash = false
	is_dashing = true
	hitbox.set_deferred("monitorable", false)
	dash_duration_timer.start(dash_duration)
	dash_cooldown_timer.start(dash_cooldown)
	dash_dir = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down")).normalized()
	if dash_dir == Vector2.ZERO:
		dash_dir = global_position.direction_to(get_global_mouse_position())


func reload():
	reload_timer.start(held_weapon["reload_time"])
	animated_sprite.play(held_weapon["name"] + "_reload")


func knockback(knockback_force):
	is_knocked_back = true
	knockback_velocity = knockback_force


func die():
	var blood_explosion = blood_explosion_scene.instantiate()
	blood_explosion.global_position = global_position
	game.add_child(blood_explosion)
	
	var blood_pool: Area2D = blood_pool_scene.instantiate()
	blood_pool.global_position = global_position
	game.call_deferred("add_child", blood_pool)
	
	var death_screen: CanvasLayer = death_screen_scene.instantiate()
	game.add_child(death_screen)
	
	queue_free()


func blink():
	var tween := tree.create_tween()
	tween.tween_method(set_blink_shader_intensity, 1.32, 0.0, 0.2)


func set_blink_shader_intensity(new_value):
	animated_sprite.material.set_shader_parameter("blink_intensity", new_value)



func _on_fire_delay_timeout():
	can_shoot = true


func _on_reload_timer_timeout():
	held_weapon["mag"] = held_weapon["mag_max"]
	animated_sprite.play(held_weapon["name"])
	emit_signal("mag_changed", held_weapon["mag"])


func _on_dash_cooldown_timeout():
	can_dash = true

func _on_dash_duration_timeout():
	is_dashing = false
	hitbox.set_deferred("monitorable", true)


func _on_blood_sucker_area_exited(area: Area2D):
	if area == blood_pool:
		blood_pool = null
		stop_sucking()
