class_name Bullet
extends CharacterBody2D

@export var speed: float = 50.0

var dir: Vector2

var dmg: int = 10
var knockback_force: float = 1500.0
var puncture: int = 0
var wall_puncture: int = 0

var shooter: CharacterBody2D
var entities_hit = []

var blood_splatter_scene = preload("uid://cwqe7churtxrv")
var dirt_splatter_scene = preload("uid://48ojgreyybe")

@onready var game: Node2D = $/root/Game
@onready var tip: Marker2D = $Tip
@onready var hitbox: Area2D = $Hitbox



func _physics_process(delta):
	velocity = dir * speed
	move_and_collide(velocity)


func _on_screen_exited():
	queue_free()


func _on_hitbox_body_entered(body: Node2D):
	if body is not CharacterBody2D:
		var dirt_splatter = dirt_splatter_scene.instantiate()
		dirt_splatter.global_position = tip.global_position
		dirt_splatter.global_rotation = global_rotation
		game.add_child(dirt_splatter)
		
		wall_puncture -= 1
		if wall_puncture <= 0:
			queue_free()


func _on_hitbox_area_entered(area: Area2D):
	if area.owner not in entities_hit:
		entities_hit.append(area.owner)
		area.owner.hp -= dmg
		area.owner.knockback(knockback_force * dir)
		
		var blood_splatter = blood_splatter_scene.instantiate()
		blood_splatter.global_position = tip.global_position
		blood_splatter.global_rotation = global_rotation
		blood_splatter.scale *= area.owner.scale
		game.add_child(blood_splatter)
		
		if entities_hit.size() > puncture:
			queue_free()
