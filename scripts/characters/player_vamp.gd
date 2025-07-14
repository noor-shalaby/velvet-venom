class_name PlayerVamp
extends Player


var fire_empty = {
	"dmg": 20,
	"fire_rate": 3.0,
	"multishot": 1,
	"spread": 20.0,
	"recoil": 24.0,
	"knockback_force": 4000,
	"puncture": 0,
	"wall_puncture": 0
}
var fire = {
	"dmg": 24,
	"fire_rate": 16.0,
	"multishot": 1,
	"spread": 30.0,
	"recoil": 16.0,
	"knockback_force": 5000,
	"puncture": 0,
	"wall_puncture": 0
}
var fire_alt = {
	"dmg": 40,
	"fire_rate": 2.0,
	"multishot": 8,
	"spread": 40.0,
	"recoil": 128.0,
	"knockback_force": 10000,
	"puncture": 1,
	"wall_puncture": 0
}


func set_hp(new_hp):
	super(new_hp)
	
	if new_hp >= hp_max:
		stop_sucking()


@export var blood_max: int = 128
@export var blood := 96:
	set = set_blood
func set_blood(new_value):
	blood = clamp(new_value, 0, blood_max)
	emit_signal("blood_changed", blood, blood_max)
	
	if new_value >= blood_max:
		stop_sucking()
signal blood_changed

var blood_tween: Tween
var active_blood_tweens = []
var blood_pool: Area2D
var is_sucking: bool = false


var bloodshot_scene = preload("uid://b4l7nhavg53cx")
var blood_splash_scene = preload("uid://c5g8ji3vl07fb")


@onready var arm_left: Sprite2D = $ArmLeft
@onready var arm_right: Sprite2D = $ArmRight
@onready var blood_sucker: Area2D = $BloodSucker

func _ready():
	super()
	
	emit_signal("blood_changed", blood, blood_max)



func _physics_process(delta):
	super(delta)
	
	if (Input.is_action_pressed("fire") or Input.is_action_pressed("fire_alt")) and can_shoot:
		var wep
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
		
		var bloodshot: Bullet = bloodshot_scene.instantiate()
		bloodshot.global_position = muzzle.global_position
		bloodshot.global_rotation = global_rotation
		bloodshot.dir = dir
		bloodshot.dmg = wep["dmg"]
		bloodshot.knockback_force = wep["knockback_force"]
		bloodshot.puncture = wep["puncture"]
		bloodshot.wall_puncture = wep["wall_puncture"]
		bloodshot.shooter = self
		game.add_child(bloodshot)
		for shot in range(wep["multishot"] - 1):
			bloodshot = bloodshot_scene.instantiate()
			bloodshot.global_position = muzzle.global_position
			bloodshot.global_rotation = global_rotation
			bloodshot.dir = Vector2.from_angle(dir.angle() + randf_range(deg_to_rad(-wep["spread"]/2), deg_to_rad(wep["spread"]/2))).normalized()
			bloodshot.dmg = wep["dmg"]
			bloodshot.knockback_force = wep["knockback_force"]
			bloodshot.puncture = wep["puncture"]
			bloodshot.wall_puncture = wep["wall_puncture"]
			bloodshot.shooter = self
			game.add_child(bloodshot)
		
		var blood_splash = blood_splash_scene.instantiate()
		muzzle.add_child(blood_splash)
		
		velocity += randf_range(0, wep["recoil"]) * -dir
	
	if Input.is_action_just_released("fire") or Input.is_action_just_released("fire_alt"):
		arm_right.hide()
	
	if Input.is_action_pressed("reload") and blood < blood_max and not is_sucking:
		blood_pool = blood_sucker.get_overlapping_areas().pop_front()
		if blood_pool:
			start_sucking(blood_pool, "blood")
		else:
			blood_pool = blood_sucker.get_overlapping_areas().pop_front()
	elif Input.is_action_pressed("suck") and hp < hp_max and not is_sucking:
		blood_pool = blood_sucker.get_overlapping_areas().pop_front()
		if blood_pool:
			start_sucking(blood_pool)
		else:
			blood_pool = blood_sucker.get_overlapping_areas().pop_front()
	
	if Input.is_action_just_released("suck") or Input.is_action_just_released("reload"):
		stop_sucking()


func _unhandled_input(event: InputEvent):
	super(event)



func start_sucking(_blood_pool: Area2D, resource := "hp"):
	arm_left.show()
	
	is_sucking = true
	if is_instance_valid(blood_tween):
		blood_tween.kill()
	blood_tween = create_tween().set_parallel(true)
	active_blood_tweens.append(blood_tween)
	blood_tween.tween_property(_blood_pool.sprite, "global_scale", Vector2.ZERO, _blood_pool.sprite.global_scale.x * 2.0)
	match resource:
		"hp":
			blood_tween.tween_property(self, "hp", hp + _blood_pool.scale.x * 50, _blood_pool.sprite.global_scale.x * 2.0)
		"blood":
			blood_tween.tween_property(self, "blood", blood + _blood_pool.scale.x * 64, _blood_pool.sprite.global_scale.x * 2.0)
	blood_tween.finished.connect(_blood_pool.queue_free)

func stop_sucking():
	arm_left.hide()
	
	is_sucking = false
	for tween in active_blood_tweens:
		if is_instance_valid(tween):
			tween.kill()
	active_blood_tweens.clear()


func _on_blood_sucker_area_exited(area: Area2D):
	if area == blood_pool:
		blood_pool = null
		stop_sucking()
