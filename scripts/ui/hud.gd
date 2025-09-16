extends CanvasLayer


@onready var hp_bar: ProgressBar = $Margin/HPPanel/HPMargin/VBox/HPBox/HPBar
@onready var blood_box: HBoxContainer = $Margin/HPPanel/HPMargin/VBox/BloodBox
@onready var blood_bar: ProgressBar = $Margin/HPPanel/HPMargin/VBox/BloodBox/BloodBar
@onready var weapon_panel: PanelContainer = $Margin/WeaponPanel
@onready var weapon_rect: TextureRect = $Margin/WeaponPanel/WeaponMargin/WeaponBox/WeaponTexture
@onready var mag_label: Label = $Margin/WeaponPanel/WeaponMargin/WeaponBox/AmmoBox/MagLabel

const WEAPON_TEXTURES: Dictionary[String, CompressedTexture2D] = {
	"gun": preload(Constants.FILE_UIDS.weapon_tex_gun),
	"machinegun": preload(Constants.FILE_UIDS.weapon_tex_machinegun),
	"shotgun": preload(Constants.FILE_UIDS.weapon_tex_shotgun)
}

func _ready() -> void:
	EventBus.connect("player_class_changed", _update_player_class)
	EventBus.connect("player_hp_changed", _update_player_hp)
	
	show()


func _update_player_class(new_value: String) -> void:
	match new_value:
		"PlayerNorm":
			blood_box.hide()
			weapon_panel.show()
			EventBus.connect("player_weapon_changed", _update_player_weapon)
			EventBus.connect("player_mag_changed", _update_player_mag)
		"PlayerVamp":
			weapon_panel.hide()
			blood_box.show()
			EventBus.connect("player_blood_changed", _update_player_blood)

func _update_player_hp(new_value: float, max_value: float) -> void:
	create_tween().tween_property(hp_bar, "value", (new_value / max_value) * 100, 0.1)

func _update_player_weapon(new_weapon_name: String) -> void:
	weapon_rect.texture = WEAPON_TEXTURES[new_weapon_name]

func _update_player_mag(new_value: int) -> void:
	mag_label.text = str(new_value)

func _update_player_blood(new_value: float, max_value: float) -> void:
	create_tween().tween_property(blood_bar, "value", (new_value / max_value) * 100, 0.1)
