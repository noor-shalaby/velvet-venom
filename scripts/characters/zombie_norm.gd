class_name ZombieNorm
extends Zombie


var sprites: Array[CompressedTexture2D] = [
	preload("uid://c62pvtxkwma4a"),
	preload("uid://b51mb2ushd3qj")
	]


func _ready() -> void:
	super()
	
	sprite.texture = sprites.pick_random()
