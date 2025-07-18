class_name Zombie
extends CharacterBody2D

@export_category("Movement")
@export var turning_speed := 0.3
@export var patrol_speed := 100.0
@export var chase_speed := 300.0
@export var friction := 0.3

@export_category("Attack")
@export var damage := 20
@export var attack_speed := 2.0
@export var knockback_force := 4800

@export_category("Health")
@export var max_hp := 60.0
var hp := max_hp:
	set = set_hp
func set_hp(new_hp):
	if new_hp < hp and not _readying:
		blink()
	
	hp = clamp(new_hp, 0, max_hp)
	
	if hp <= 0:
		die()

var dir: Vector2
var movement_speed = patrol_speed

var is_knocked_back = false
var knockback_velocity: Vector2

var target: CharacterBody2D:
	set = set_target
func set_target(new_target):
	target = new_target
	if target:
		movement_speed = lerp(movement_speed, chase_speed, 0.1)
		comm_area.set_deferred("monitoring", true)
	else:
		movement_speed = lerp(movement_speed, patrol_speed, 0.1)
		comm_area.set_deferred("monitoring", false)
var target_in_vision: CharacterBody2D


var blood_splatter_scene = preload("uid://cwqe7churtxrv")
var blood_explosion_scene = preload("uid://cs6dxwtk5651p")
var blood_pool_scene = preload("uid://1twhq540r50")



@onready var game: Node2D = $/root/Game
@onready var attack_hitbox: Area2D = $AttackHitbox
@onready var attack_delay: Timer = $AttackDelay
@onready var nav_agent: NavigationAgent2D = $NavAgent
@onready var nav_region: NavigationRegion2D = game.get_node("NavRegion")
@onready var comm_area: Area2D = $CommArea
@onready var comm_eye: RayCast2D = $CommEye
@onready var eye_group: Node2D = $EyeGroup
@onready var eyes = eye_group.get_children()
@onready var sprite = $Sprite
@onready var vis_notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier
@onready var vis_enabler: VisibleOnScreenEnabler2D = $VisibleOnScreenEnabler

var _readying: bool = true

func _ready():
	global_rotation_degrees = randf_range(-180.0, 180.0)
	hp = max_hp
	_readying = false



func _physics_process(delta):
	look_for_target()
	
	var next_path_pos = nav_agent.get_next_path_position()
	dir = global_position.direction_to(next_path_pos)
	global_rotation = lerp_angle(global_rotation, (next_path_pos - global_position).angle(), turning_speed)
	velocity = movement_speed * dir
	
	handle_knockback()
	
	move_and_slide()


func look_for_target():
	if target_in_vision:
		for eye in eyes:
			eye.set_deferred("enabled", true)
			eye.target_position.x = global_position.distance_to(target_in_vision.global_position)
		eye_group.look_at(target_in_vision.global_position)
		if eyes_on_target(target_in_vision) > 1:
			target = target_in_vision


func eyes_on_target(_target) -> int:
	var _eyes_on_target: int = 0
	for eye in eyes:
		if eye.is_colliding():
			var collider = eye.get_collider()
			if collider == _target:
				_eyes_on_target += 1
	return _eyes_on_target


func make_path():
	if target:
		nav_agent.target_position = target.global_position
	elif get_real_velocity().length() < movement_speed * 0.8 or nav_agent.is_target_reached() or global_position.distance_to(nav_agent.get_next_path_position()) < movement_speed / 100:
		nav_agent.target_position = get_random_nav_point(nav_region)


func handle_knockback():
	if is_knocked_back:
		velocity += knockback_velocity
		velocity = lerp(get_real_velocity(), velocity, friction)
		is_knocked_back = false


func knockback(knockback_force):
	is_knocked_back = true
	knockback_velocity = knockback_force


func die():
	var blood_explosion = blood_explosion_scene.instantiate()
	blood_explosion.global_position = global_position
	blood_explosion.scale *= scale
	game.add_child(blood_explosion)
	
	var blood_pool: Area2D = blood_pool_scene.instantiate()
	blood_pool.global_position = global_position
	blood_pool.scale *= scale
	game.call_deferred("add_child", blood_pool)
	
	queue_free()


func blink():
	create_tween().tween_method(set_blink_shader_intensity, 1.32, 0.0, 0.2)


func set_blink_shader_intensity(new_value):
	sprite.material.set_shader_parameter("blink_intensity", new_value)



func _on_attack_hitbox_area_entered(area: Area2D):
	area.owner.hp -= damage
	max_hp += damage
	hp += damage
	area.owner.knockback(knockback_force * dir)
	attack_hitbox.set_deferred("monitoring", false)
	attack_delay.start(1.0/attack_speed)
	
	var blood_splatter = blood_splatter_scene.instantiate()
	blood_splatter.global_position = area.global_position
	blood_splatter.global_rotation = global_rotation
	game.add_child(blood_splatter)


func _on_attack_delay_timeout():
	attack_hitbox.set_deferred("monitoring", true)


func _on_nav_timer_timeout():
	make_path()


func _on_vision_area_body_entered(body: CharacterBody2D):
	if body is CharacterBody2D:
		target_in_vision = body


func _on_vision_area_body_exited(body: CharacterBody2D):
	if body == target_in_vision:
		target_in_vision = null


func _on_comm_area_body_entered(body: CharacterBody2D):
	comm_eye.set_deferred("enabled", true)
	for _body in comm_area.get_overlapping_bodies():
		if _body.is_in_group("mobs"):
			comm_eye.look_at(_body.global_position)
			if target:
				_body.set_target(target)


func _on_hitbox_area_entered(area: Area2D):
	if area.owner is Bullet:
		if area.owner.shooter:
			target = area.owner.shooter


func _on_screen_entered():
	target_in_vision = game.get_node_or_null("Player")
	if vis_enabler:
		vis_enabler.queue_free()

func _on_screen_exited():
	pass


func get_random_nav_point(nav_region: NavigationRegion2D) -> Vector2:
	var nav_poly: NavigationPolygon = nav_region.navigation_polygon
	if not nav_poly:
		push_error("No NavigationPolygon found")
		return Vector2.ZERO

	var vertices: PackedVector2Array = nav_poly.get_vertices()
	var poly_count: int = nav_poly.get_polygon_count()
	
	if poly_count == 0:
		push_error("NavigationPolygon has no polygons")
		return Vector2.ZERO

	# Build list of all triangles from all polygons
	var all_triangles: Array = []
	
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
	var triangle_areas: Array = []
	
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
	return nav_region.to_global(local_point)

func get_triangle_area(a: Vector2, b: Vector2, c: Vector2) -> float:
	return abs((b - a).cross(c - a)) / 2.0
