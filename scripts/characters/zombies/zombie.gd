class_name Zombie
extends CharacterBody2D

@export_category("Movement")
@export var turning_speed: float = 18.0
@export var patrol_speed: float = 100.0
@export var chase_speed: float = 300.0
@export var friction: float = 18.0

@export_category("Attack")
@export var damage: float = 20
@export var attack_speed: float = 2.0
@export var knockback_force: float = 4800.0

@export_category("Health")
@export var hp_max: float = 60.0
var hp: float = hp_max:
	set = set_hp
func set_hp(new_hp: float) -> void:
	if new_hp < hp and not _readying:
		blink()
		
		if is_pain_vocal_ready and Settings.audio:
			var pain_vocal: AudioStreamPlayer2D = PAIN_VOCAL_SCENE.instantiate()
			pain_vocal.stream = Constants.ZOMBIE_PAIN_VOCALS.pick_random()
			pain_vocal.volume_db += scale.x
			pain_vocal.pitch_scale /= scale.x
			pain_vocal.global_position = global_position
			game.add_child(pain_vocal)
			is_pain_vocal_ready = false
			pain_vocal_cooldown_timer.start(pain_vocal_cooldown_duration)
	
	hp = clamp(new_hp, 0, hp_max)
	
	if hp <= 0:
		die()

@export_category("Appearance")
@export var blood_color: Color = Color(0.502, 0.141, 0.11)

@export_category("Patrol Limits")
@export var patrol_limit_left: float
@export var patrol_limit_right: float
@export var patrol_limit_top: float
@export var patrol_limit_bottom: float

var dir: Vector2
var movement_speed: float = patrol_speed

var is_knocked_back: bool = false
var knockback_velocity: Vector2

var is_stunned: bool = false:
	set = set_is_stunned
func set_is_stunned(new_value: bool) -> void:
	is_stunned = new_value
	if is_stunned:
		hitbox.set_deferred("monitoring", false)
		velocity = Vector2.ZERO
	else:
		hitbox.set_deferred("monitoring", true)

var target: CharacterBody2D:
	set = set_target
func set_target(new_target: CharacterBody2D) -> void:
	if not is_instance_valid(new_target):
		new_target = null
	target = new_target
	if target:
		movement_speed = lerp(movement_speed, chase_speed, 6.0 * get_process_delta_time())
		comm_area.set_deferred("monitoring", true)
	else:
		movement_speed = lerp(movement_speed, patrol_speed, 6.0 * get_process_delta_time())
		comm_area.set_deferred("monitoring", false)
var target_in_vision: CharacterBody2D


const BLOOD_SPLATTER_SCENE: PackedScene = preload(Constants.FILE_UIDS.blood_splatter_scene)
const BLOOD_EXPLOSION_SCENE: PackedScene = preload(Constants.FILE_UIDS.blood_explosion_scene)
const BLOOD_POOL_SCENE: PackedScene = preload(Constants.FILE_UIDS.blood_pool_scene)
const ATTACK_VOCAL_SCENE: PackedScene = preload(Constants.FILE_UIDS.zombie_attack_vocal_scene)
const PAIN_VOCAL_SCENE: PackedScene = preload(Constants.FILE_UIDS.zombie_pain_vocal_scene)
const DEATH_SOUND_SCENE: PackedScene = preload(Constants.FILE_UIDS.zombie_death_sound_scene)


@onready var game: Node2D = $/root/Game
@onready var hitbox: Area2D = $Hitbox
@onready var attack_delay: Timer = $AttackDelay
@onready var nav_agent: NavigationAgent2D = $NavAgent
@onready var nav_region: NavigationRegion2D = game.get_node("NavRegion")
@onready var map_rid: RID = nav_region.get_region_rid()
@onready var comm_area: Area2D = $CommArea
@onready var comm_eye: RayCast2D = $CommEye
@onready var eye_group: Node2D = $EyeGroup
@onready var eyes: Array[Node] = eye_group.get_children()
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var vis_notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier
@onready var vis_enabler: VisibleOnScreenEnabler2D = $VisibleOnScreenEnabler
@onready var stun_timer: Timer = $StunTimer
@onready var blood_stain_cooldown_timer: Timer = $BloodStainCooldown
@onready var pain_vocal_cooldown_timer: Timer = $PainVocalCooldown

var _readying: bool = true

var is_blood_stain_ready: bool = true
var blood_stain_cooldown: float = 0.1:
	set = set_is_blood_stain_ready
func set_is_blood_stain_ready(new_value: bool) -> void:
	is_blood_stain_ready = new_value
	if not is_blood_stain_ready:
		blood_stain_cooldown_timer.start(blood_stain_cooldown)

var pain_vocal_cooldown_duration: float = 0.5
var is_pain_vocal_ready: bool = true

var attack_vocal: AudioStreamPlayer2D

func _ready() -> void:
	global_rotation_degrees = randf_range(-180.0, 180.0)
	
	var vitality_facto: float = randf_range(-Constants.RANDOFACTO_SUBTLE, Constants.RANDOFACTO_SUBTLE)
	hp_max += hp_max * vitality_facto
	hp = hp_max
	scale += scale * vitality_facto
	
	var speed_facto: float = randf_range(-Constants.RANDOFACTO, Constants.RANDOFACTO)
	patrol_speed += patrol_speed * speed_facto
	chase_speed += chase_speed * speed_facto
	attack_speed += attack_speed * speed_facto
	
	var strength_facto: float = randf_range(-Constants.RANDOFACTO, Constants.RANDOFACTO)
	damage += damage * strength_facto
	knockback_force += knockback_force * strength_facto
	
	if vis_notifier.is_on_screen():
		_on_screen_entered()
	
	pain_vocal_cooldown_timer.wait_time = pain_vocal_cooldown_duration
	_readying = false



func _physics_process(delta: float) -> void:
	if nav_region.get_rid():
		get_random_valid_point()
	look_for_target()
	
	if not is_stunned:
		var next_path_pos: Vector2 = nav_agent.get_next_path_position()
		dir = global_position.direction_to(next_path_pos)
		global_rotation = lerp_angle(global_rotation, (next_path_pos - global_position).angle(), turning_speed * delta)
		velocity = movement_speed * dir
	
	handle_knockback()
	
	move_and_slide()


func look_for_target() -> void:
	if target_in_vision:
		for eye: RayCast2D in eyes:
			eye.set_deferred("enabled", true)
			eye.target_position.x = global_position.distance_to(target_in_vision.global_position)
		eye_group.look_at(target_in_vision.global_position)
		if eyes_on_target(target_in_vision) > 1:
			target = target_in_vision


func eyes_on_target(_target: CharacterBody2D) -> int:
	var _eyes_on_target: int = 0
	for eye: RayCast2D in eyes:
		if eye.is_colliding():
			var collider: Node2D = eye.get_collider()
			if collider == _target:
				_eyes_on_target += 1
	return _eyes_on_target


func make_path() -> void:
	if target:
		nav_agent.target_position = target.global_position
	elif get_real_velocity().length() < movement_speed * 0.8 or nav_agent.is_target_reached() or global_position.distance_to(nav_agent.get_next_path_position()) < movement_speed / 100:
		nav_agent.target_position = get_random_nav_point(nav_region)


func handle_knockback() -> void:
	if is_knocked_back:
		velocity += knockback_velocity
		velocity = lerp(get_real_velocity(), velocity, friction * get_process_delta_time())
		is_knocked_back = false


func knockback(_knockback_force: Vector2) -> void:
	is_knocked_back = true
	knockback_velocity = _knockback_force


func stunned(duration: float) -> void:
	is_stunned = true
	stun_timer.start(duration)

func _on_stun_timer_timeout() -> void:
	is_stunned = false


func die() -> void:
	var blood_explosion: ParticleEffect = BLOOD_EXPLOSION_SCENE.instantiate()
	blood_explosion.global_position = global_position
	blood_explosion.scale *= scale
	game.add_child(blood_explosion)
	
	var blood_pool: Area2D = BLOOD_POOL_SCENE.instantiate()
	blood_pool.global_position = global_position
	blood_pool.scale *= scale
	game.call_deferred("add_child", blood_pool)
	
	if Settings.audio:
		var death_sound: AudioStreamPlayer2D = DEATH_SOUND_SCENE.instantiate()
		death_sound.global_position = global_position
		death_sound.stream = Constants.ZOMBIE_DEATH_SOUNDS.pick_random()
		game.add_child(death_sound)
	
	queue_free()


func blink() -> void:
	create_tween().tween_method(set_blink_shader_intensity, 1.32, 0.0, 0.2)


func set_blink_shader_intensity(new_value: float) -> void:
	sprite.material.set_shader_parameter("blink_intensity", new_value)



func _on_hitbox_area_entered(area: Area2D) -> void:
	area.owner.hp -= damage
	hp_max += damage
	hp += damage
	area.owner.knockback(knockback_force * dir)
	hitbox.set_deferred("monitoring", false)
	attack_delay.start(1.0/attack_speed)
	
	var blood_splatter: ParticleEffect = BLOOD_SPLATTER_SCENE.instantiate()
	blood_splatter.global_position = area.global_position
	blood_splatter.global_rotation = global_rotation
	blood_splatter.color = area.owner.blood_color
	game.add_child(blood_splatter)
	
	EventBus.emit_signal("player_hit", damage)
	
	if Settings.audio:
		if attack_vocal:
			return
		attack_vocal = ATTACK_VOCAL_SCENE.instantiate()
		attack_vocal.global_position = global_position
		attack_vocal.stream = Constants.ZOMBIE_ATTACK_VOCALS.pick_random()
		attack_vocal.volume_db += scale.x
		attack_vocal.pitch_scale /= scale.x
		game.add_child(attack_vocal)


func _on_attack_delay_timeout() -> void:
	hitbox.set_deferred("monitoring", true)


func _on_nav_timer_timeout() -> void:
	if not is_stunned:
		make_path()


func _on_blood_stain_cooldown_timeout() -> void:
	is_blood_stain_ready = true


func _on_pain_vocal_cooldown_timeout() -> void:
	is_pain_vocal_ready = true


func _on_vision_area_body_entered(body: CharacterBody2D) -> void:
	if body is CharacterBody2D:
		target_in_vision = body


func _on_vision_area_body_exited(body: CharacterBody2D) -> void:
	if body == target_in_vision:
		target_in_vision = null


func _on_comm_area_body_entered(_body: CharacterBody2D) -> void:
	comm_eye.set_deferred("enabled", true)
	for overlapping_body in comm_area.get_overlapping_bodies():
		if overlapping_body.is_in_group("enemies"):
			if overlapping_body.target:
				continue
			comm_eye.look_at(overlapping_body.global_position)
			if target:
				if Settings.audio:
					AudioManager.play_zombie_alert_vocal(global_position, scale.x)
				overlapping_body.set_target(target)


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if target:
		return
	if area is Bullet:
		if area.shooter:
			if area.shooter.is_in_group("enemies"):
				return
			target = area.shooter


func _on_screen_entered() -> void:
	target_in_vision = EventBus.player
	if vis_enabler:
		vis_enabler.queue_free()

func _on_screen_exited() -> void:
	pass


func get_random_valid_point() -> Vector2:
	if not map_rid:
		return Vector2.ZERO
	print("hey")
	# Define a Rect2 from your limits
	var rect: Rect2 = Rect2(Vector2(patrol_limit_left, patrol_limit_top), Vector2(patrol_limit_right - patrol_limit_left, patrol_limit_bottom - patrol_limit_top))
	
	# Loop to try and find a valid point
	# We use a limited number of attempts to avoid an infinite loop
	var max_attempts: int = 100
	for i in range(max_attempts):
		# Generate a random point within the defined rectangle
		var random_point: Vector2 = Vector2(
			randf_range(rect.position.x, rect.end.x),
			randf_range(rect.position.y, rect.end.y)
		)
		
		# Get the closest point on the navigation mesh
		var closest_point: Vector2 = NavigationServer2D.map_get_closest_point(map_rid, random_point)
		
		# Check if the generated point is close enough to a valid nav mesh point
		if random_point.distance_to(closest_point) < 1.0: # Tolerance of 1.0
			return closest_point
		
	# Return null if no valid point is found after all attempts
	return Vector2.ZERO


func get_random_nav_point(_nav_region: NavigationRegion2D) -> Vector2:
	var nav_poly: NavigationPolygon = _nav_region.navigation_polygon
	if not nav_poly:
		push_error("No NavigationPolygon found")
		return Vector2.ZERO

	var vertices: PackedVector2Array = nav_poly.get_vertices()
	var poly_count: int = nav_poly.get_polygon_count()
	
	if poly_count == 0:
		push_error("NavigationPolygon has no polygons")
		return Vector2.ZERO

	# Build list of all triangles from all polygons
	var all_triangles: Array[PackedInt32Array] = []
	
	for i in range(poly_count):
		var poly: PackedInt32Array = nav_poly.get_polygon(i)
		var poly_vert_count: int = poly.size()
		
		# Skip invalid polygons
		if poly_vert_count < 3:
			continue
			
		# Triangulate polygon by fanning from first vertex
		for j in range(1, poly_vert_count - 1):
			var triangle: PackedInt32Array = [poly[0], poly[j], poly[j + 1]]
			all_triangles.append(triangle)

	if all_triangles.is_empty():
		push_error("No valid triangles found in navigation polygon")
		return Vector2.ZERO

	# Calculate areas for all triangles
	var total_area: float = 0.0
	var triangle_areas: Array[float] = []
	
	for tri in all_triangles:
		var a: Vector2 = vertices[tri[0]]
		var b: Vector2 = vertices[tri[1]]
		var c: Vector2 = vertices[tri[2]]
		var area: float = get_triangle_area(a, b, c)
		triangle_areas.append(area)
		total_area += area

	# Select random triangle weighted by area
	var rand_val: float = randf_range(0.0, total_area)
	var accum_area: float = 0.0
	var selected_tri: PackedInt32Array
	
	for i in range(all_triangles.size()):
		accum_area += triangle_areas[i]
		if accum_area >= rand_val:
			selected_tri = all_triangles[i]
			break

	# Get triangle vertices
	var A: Vector2 = vertices[selected_tri[0]]
	var B: Vector2 = vertices[selected_tri[1]]
	var C: Vector2 = vertices[selected_tri[2]]
	
	# Generate random point in triangle
	var u: float = randf()
	var v: float = randf()
	
	if u + v > 1.0:
		u = 1.0 - u
		v = 1.0 - v
	
	var local_point: Vector2 = A + u * (B - A) + v * (C - A)
	return _nav_region.to_global(local_point)

func get_triangle_area(a: Vector2, b: Vector2, c: Vector2) -> float:
	return abs((b - a).cross(c - a)) / 2.0
