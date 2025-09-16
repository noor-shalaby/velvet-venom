class_name ZombieNorm
extends Zombie


const SPRITESHEETS: Array[SpriteFrames] = [
	preload(Constants.FILE_UIDS.zombie_norm1_spriteframes),
	preload(Constants.FILE_UIDS.zombie_norm2_spriteframes)
	]


func _ready() -> void:
	super()
	
	sprite.sprite_frames = SPRITESHEETS.pick_random()
	sprite.play("hold")


func stunned(duration: float) -> void:
	super(duration)
	
	sprite.play("stand")

func _on_stun_timer_timeout() -> void:
	super()
	
	sprite.play("hold")
