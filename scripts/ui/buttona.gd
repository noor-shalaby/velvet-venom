class_name Buttona
extends Button


@export var hover_scale: float = 1.1
@export var hover_animation_duration: float = 0.1
@export var unhover_animation_duration: float = 0.2
@export var sfx: PackedScene = AudioManager.CLICK_SOUND_SCENE


var tween: Tween


func _ready() -> void:
	set_deferred("pivot_offset", size / 2)


func focus() -> void:
	grab_focus()
	grab_click_focus()
	
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE * hover_scale, hover_animation_duration)

func unfocus() -> void:
	release_focus()
	
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, unhover_animation_duration)


func _on_pressed() -> void:
	if sfx and Settings.audio:
		AudioManager.play_oneshot(sfx)


func _on_mouse_entered() -> void:
	if disabled:
		return
	focus()

func _on_mouse_exited() -> void:
	if disabled:
		return
	unfocus()


func _on_focus_entered() -> void:
	if disabled:
		return
	focus()

func _on_focus_exited() -> void:
	if disabled:
		return
	unfocus()


func _on_resized() -> void:
	set_deferred("pivot_offset", size / 2)
