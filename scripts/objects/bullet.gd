class_name Bullet
extends Area2D

@export var speed: float = 3000.0

var dir: Vector2

var dmg: int = 10
var knockback_force: float = 1500.0
var puncture: int = 0
var wall_puncture: int = 0

var shooter: CharacterBody2D
var entities_hit: Array[PhysicsBody2D] = []

const BLOOD_SPLATTER_SCENE: PackedScene = preload(Constants.FILE_UIDS["blood_splatter_scene"])
const DIRT_SPLATTER_SCENE: PackedScene = preload(Constants.FILE_UIDS["dirt_splatter_scene"])
const IMPACT_SOUND_SCENE: PackedScene = preload(Constants.FILE_UIDS["impact_sound_scene"])
const IMPACT_SOUNDS: Array[AudioStreamWAV] = [
	preload(Constants.FILE_UIDS["impact_sound1"]),
	preload(Constants.FILE_UIDS["impact_sound2"]),
	preload(Constants.FILE_UIDS["impact_sound3"]),
	preload(Constants.FILE_UIDS["impact_sound4"])
]

@onready var game: Node2D = $/root/Game
@onready var tip: Marker2D = $Tip


func _physics_process(delta: float) -> void:
	global_position += speed * dir * delta


func _on_screen_exited() -> void:
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is not CharacterBody2D:
		var dirt_splatter: ParticleEffect = DIRT_SPLATTER_SCENE.instantiate()
		dirt_splatter.global_position = tip.global_position
		dirt_splatter.global_rotation = global_rotation
		game.add_child(dirt_splatter)
		
		if Settings.audio:
			var impact_sound: AudioStreamPlayer2D = IMPACT_SOUND_SCENE.instantiate()
			impact_sound.stream = IMPACT_SOUNDS.pick_random()
			impact_sound.global_position = tip.global_position
			game.add_child(impact_sound)
		
		wall_puncture -= 1
		if wall_puncture <= 0:
			queue_free()


func _on_area_entered(area: Area2D) -> void:
	if not shooter or not area.owner:
		return
	if area.owner.is_in_group("enemies") == shooter.is_in_group("enemies"):
		return
	if area.owner not in entities_hit and entities_hit.size() <= puncture:
		entities_hit.append(area.owner)
		area.owner.hp -= dmg
		area.owner.knockback(knockback_force * dir)
		
		if (area.owner.is_in_group("enemies") and area.owner.is_blood_stain_ready) or not area.owner.is_in_group("enemies"):
			var blood_splatter: ParticleEffect = BLOOD_SPLATTER_SCENE.instantiate()
			blood_splatter.global_position = tip.global_position
			blood_splatter.global_rotation = global_rotation
			blood_splatter.scale *= area.owner.scale
			blood_splatter.color = area.owner.blood_color
			game.add_child(blood_splatter)
			
			if area.owner.is_in_group("enemies"):
				area.owner.set_is_blood_stain_ready(false)
		
		if entities_hit.size() > puncture:
			queue_free()
