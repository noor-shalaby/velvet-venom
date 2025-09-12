extends Pickup


@export var weapon: String = "machinegun"

const WEAPON_TEXTURES: Dictionary[String, CompressedTexture2D] = {
	"gun": preload(Constants.FILE_UIDS["weapon_tex_gun"]),
	"machinegun": preload(Constants.FILE_UIDS["weapon_tex_machinegun"]),
	"shotgun": preload(Constants.FILE_UIDS["weapon_tex_shotgun"])
}


@onready var sprite := $Sprite

func _ready() -> void:
	sprite.texture = WEAPON_TEXTURES[weapon]


func _on_body_entered(body: Player) -> void:
	if body is PlayerNorm:
		body.held_weapons[body.weapons[weapon]["index"]] = body.weapons[weapon]
		body.held_weapon = body.held_weapons[body.weapons[weapon]["index"]]
		
		picked_up()
