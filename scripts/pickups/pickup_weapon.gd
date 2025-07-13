extends Pickup


@export var weapon := "machinegun"

var sprites = {
	"gun": preload("uid://bygmehm306uvm"),
	"machinegun": preload("uid://ds5ibso7vge53"),
	"shotgun": preload("uid://cohyjtj6jsj5q")
}


@onready var sprite := $Sprite

func _ready():
	sprite.texture = sprites[weapon]


func _on_body_entered(body: Node2D):
	if body is PlayerNorm:
		body.held_weapons[body.weapons[weapon]["index"]] = body.weapons[weapon]
		body.held_weapon = body.held_weapons[body.weapons[weapon]["index"]]
		
		var tween: Tween = get_tree().create_tween().set_parallel(true)
		tween.tween_property(self, "scale", Vector2.ZERO, animation_speed)
		tween.tween_property(self, "modulate:a", 0.0, animation_speed)
		tween.connect("finished", queue_free)
