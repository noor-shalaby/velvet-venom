class_name Player
extends CharacterBody2D

@export_category("Movement")
@export var movement_speed: float = 350.0
@export_range(0.0, 1.0, 0.01) var friction: float = 0.3

@export_category("Dash")
@export var dash_speed: float = 1300.0
@export var dash_duration: float = 0.05
@export var dash_cooldown: float = 0.2

@export_category("Stats")
@export var hp_max: float = 100.0
var hp: float = hp_max:
	set = set_hp
func set_hp(new_hp):
	if new_hp < hp:
		blink()
		cam_ctrl.screenshake((float(hp - new_hp) / hp_max) * 40, 0.2)
	
	hp = clamp(new_hp, 0, hp_max)
	emit_signal("hp_changed", hp, hp_max)
	
	if hp <= 0:
		die()
signal hp_changed
signal dead


var dir: Vector2
var input_dir: Vector2

var can_shoot: bool = true

var can_dash: bool = true
var dash_dir: Vector2
var is_dashing: bool = false

var is_knocked_back: bool = false
var knockback_velocity: Vector2

var blood_explosion_scene = preload("uid://cs6dxwtk5651p")
var blood_pool_scene = preload("uid://1twhq540r50")
var death_screen_scene = preload("uid://bomjpnrcspvgr")

var cam_ctrl: Node2D


@onready var game: Node2D = $/root/Game
@onready var sprite = $Sprite
@onready var hitbox: Area2D = $Hitbox
@onready var muzzle: Marker2D = $Muzzle
@onready var fire_delay: Timer = $FireDelay
@onready var dash_duration_timer: Timer = $DashDuration
@onready var dash_cooldown_timer: Timer = $DashCooldown
@onready var dash_particles: GPUParticles2D = $DashParticles

func _ready():
	emit_signal("hp_changed", hp, hp_max)



func _physics_process(delta):
	look_at(get_global_mouse_position())
	dir = global_position.direction_to(get_global_mouse_position())
	
	input_dir = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down")).normalized()
	
	if not is_dashing:
		velocity = movement_speed * input_dir
		velocity = lerp(get_real_velocity(), velocity, friction)
	
	if is_dashing:
		velocity = dash_speed * dash_dir
		dash_particles.emitting = true
		dash_particles.scale = input_dir
	
	if is_knocked_back:
		velocity += knockback_velocity
		velocity = lerp(get_real_velocity(), velocity, friction)
		is_knocked_back = false
	
	move_and_slide()


func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("dash") and can_dash and not is_dashing:
		dash()



func dash():
	can_dash = false
	is_dashing = true
	hitbox.set_deferred("monitorable", false)
	dash_duration_timer.start(dash_duration)
	dash_cooldown_timer.start(dash_cooldown)
	dash_dir = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down")).normalized()
	if dash_dir == Vector2.ZERO:
		dash_dir = global_position.direction_to(get_global_mouse_position())


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
	create_tween().tween_method(set_blink_shader_intensity, 1.32, 0.0, 0.2)

func set_blink_shader_intensity(new_value):
	sprite.material.set_shader_parameter("blink_intensity", new_value)


func _on_fire_delay_timeout():
	can_shoot = true


func _on_dash_cooldown_timeout():
	can_dash = true

func _on_dash_duration_timeout():
	is_dashing = false
	hitbox.set_deferred("monitorable", true)
