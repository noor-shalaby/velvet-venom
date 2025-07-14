extends CanvasLayer


@export var host: CharacterBody2D


@onready var tree: SceneTree = get_tree()
@onready var hp_bar: ProgressBar = $Margin/HPPanel/HPMargin/VBox/HPBox/HPBar
@onready var blood_box: HBoxContainer = $Margin/HPPanel/HPMargin/VBox/BloodBox
@onready var blood_bar: ProgressBar = $Margin/HPPanel/HPMargin/VBox/BloodBox/BloodBar
@onready var weapon_panel: PanelContainer = $Margin/WeaponPanel
@onready var weapon_rect: TextureRect = $Margin/WeaponPanel/WeaponMargin/WeaponBox/WeaponTexture
@onready var mag_label: Label = $Margin/WeaponPanel/WeaponMargin/WeaponBox/AmmoBox/MagLabel

var weapon_textures = {
	"gun": preload("uid://ddgwxtq3x1dsc"),
	"machinegun": preload("uid://u8ok0u51cm5j"),
	"shotgun": preload("uid://ccrxdbxnrhtkm")
}

func _ready():
	host.connect("hp_changed", update_hp)
	
	if host is PlayerNorm:
		host.connect("weapon_changed", update_weapon)
		host.connect("mag_changed", update_mag)
		blood_box.hide()
	else:
		host.connect("blood_changed", update_blood)
		weapon_panel.hide()
	
	show()


func update_hp(new_value, max_value):
	var tween = tree.create_tween()
	tween.tween_property(hp_bar, "value", (float(new_value) / float(max_value)) * 100, 0.1)

func update_weapon(new_weapon_name):
	weapon_rect.texture = weapon_textures[new_weapon_name]

func update_mag(new_value):
	mag_label.text = str(new_value)

func update_blood(new_value, max_value):
	var tween = tree.create_tween()
	tween.tween_property(blood_bar, "value", (float(new_value) / float(max_value)) * 100, 0.1)
