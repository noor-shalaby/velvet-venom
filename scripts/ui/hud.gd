extends CanvasLayer


const BLOOD_OVERLAY_THRESHOLD: float = 0.5
const BLOOD_OVERLAY_VISIBILITY_MULTIPLIER: float = 2.0

@onready var control: Control = $Control
@onready var blood_overlay_hit: TextureRect = $BloodOverlayHit
@onready var blood_overlay: TextureRect = $Control/BloodOverlay
@onready var hp_bar: ProgressBar = %HPBar
@onready var blood_box: HBoxContainer = %BloodBox
@onready var blood_bar: ProgressBar = %BloodBar
@onready var weapon_panel: PanelContainer = %WeaponPanel
@onready var weapon_rect: TextureRect = %WeaponRect
@onready var mag_label: Label = %MagLabel

const WEAPON_TEXTURES: Dictionary[String, CompressedTexture2D] = {
	"gun": preload(Constants.FILE_UIDS.weapon_tex_gun),
	"machinegun": preload(Constants.FILE_UIDS.weapon_tex_machinegun),
	"shotgun": preload(Constants.FILE_UIDS.weapon_tex_shotgun)
}

func _ready() -> void:
	EventBus.connect("player_class_changed", _update_player_class)
	EventBus.connect("player_hp_changed", _update_player_hp)
	EventBus.connect("player_hit", blink_blood)
	EventBus.connect("player_died", disappear)
	
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
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(hp_bar, "value", (new_value / max_value) * 100, 0.1)
	tween.tween_property(blood_overlay, "modulate:a", (((max_value - new_value) / max_value) - (1.0 - BLOOD_OVERLAY_THRESHOLD)) * BLOOD_OVERLAY_VISIBILITY_MULTIPLIER, 0.1)

func _update_player_weapon(new_weapon_name: String) -> void:
	weapon_rect.texture = WEAPON_TEXTURES[new_weapon_name]

func _update_player_mag(new_value: int) -> void:
	mag_label.text = str(new_value)

func _update_player_blood(new_value: float, max_value: float) -> void:
	create_tween().tween_property(blood_bar, "value", (new_value / max_value) * 100, 0.1)


func blink_blood(damage: float) -> void:
	blood_overlay_hit.show()
	var tween: Tween = create_tween()
	tween.tween_property(blood_overlay_hit, "modulate:a", (damage / EventBus.player.hp_max) * 3, 0.1)
	await tween.finished
	tween.kill()
	tween = create_tween()
	tween.tween_property(blood_overlay_hit, "modulate:a", 0.0, 0.1)
	await tween.finished
	blood_overlay_hit.hide()

func disappear() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(control, "modulate:a", 0.0, 0.1)
	await tween.finished
	hide()
