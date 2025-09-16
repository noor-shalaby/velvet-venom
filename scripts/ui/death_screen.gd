extends CanvasLayer


@export var animation_duration: float = 0.1

@onready var viewport: Viewport = get_viewport()
@onready var dim: PanelContainer = $Dim
@onready var blood_overlay: TextureRect = $Dim/BloodOverlay
@onready var retry_button: Buttona = %RetryButton

const BLOOD_OVERLAY_TEXTURES: Array[CompressedTexture2D] = [
	preload(Constants.FILE_UIDS.bloodslash1),
	preload(Constants.FILE_UIDS.bloodsplash2),
	preload(Constants.FILE_UIDS.bloodsplash_heavy),
	preload(Constants.FILE_UIDS.bloodsplat),
	preload(Constants.FILE_UIDS.bloodspray),
]


func _ready() -> void:
	retry_button.grab_focus()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if Settings.audio:
		AudioManager.play_death()
	
	blood_overlay.texture = BLOOD_OVERLAY_TEXTURES.pick_random()
	blood_overlay.flip_h = bool(randi_range(0, 1))
	blood_overlay.flip_v = bool(randi_range(0, 1))
	
	dim.modulate.a = 0.0
	var tween: Tween = create_tween()
	tween.tween_property(dim, "modulate:a", 1.0, animation_duration)


func _input(event: InputEvent) -> void:
	if viewport.gui_get_focus_owner():
		return
	
	if event.is_action_pressed("ui_down") or event.is_action_pressed("ui_up") or event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right") or event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_focus_next"):
		retry_button.grab_focus()
