extends Zombie


@onready var punch_animation_duration_timer: Timer = $PunchAnimationDuration
const SPRITESHEETS: Array[SpriteFrames] = [
	preload(Constants.FILE_UIDS["zombie_brawler1_spriteframes"]),
	preload(Constants.FILE_UIDS["zombie_brawler2_spriteframes"])
]
const PUNCH_ANIMATIONS: Array[String] = [
	"punch_left",
	"punch_right"
]


func _ready() -> void:
	super()
	
	sprite.sprite_frames = SPRITESHEETS.pick_random()
	sprite.play("stand")


func knockback(_knockback_force: Vector2) -> void:
	pass


func _on_hitbox_area_entered(area: Area2D) -> void:
	super(area)
	
	sprite.play(PUNCH_ANIMATIONS.pick_random())
	punch_animation_duration_timer.start()


func _on_punch_animation_duration_timeout() -> void:
	sprite.play("stand")


func stunned(duration: float) -> void:
	super(duration)
	
	sprite.play("stand")
