extends Zombie


@onready var punch_animation_duration_timer: Timer = $PunchAnimationDuration
var spritesheets: Array[SpriteFrames] = [
	preload("uid://0d3d8osuw42l"),
	preload("uid://bvwf6h3qnn4f5")
]
var punch_animations: Array[String] = [
	"punch_left",
	"punch_right"
]


func _ready() -> void:
	super()
	sprite.sprite_frames = spritesheets.pick_random()
	sprite.play("stand")


func knockback(knockback_force: Vector2) -> void:
	pass


func _on_attack_hitbox_area_entered(area: Area2D) -> void:
	super(area)
	sprite.play(punch_animations.pick_random())
	punch_animation_duration_timer.start()


func _on_punch_animation_duration_timeout() -> void:
	sprite.play("stand")
