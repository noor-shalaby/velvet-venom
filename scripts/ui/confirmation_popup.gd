extends CanvasLayer


@export var animation_duration_popup: float = 0.1
@export var animation_duration_unpopup: float = 0.2

var tween: Tween

@onready var viewport: Viewport = get_viewport()
@onready var panel: PanelContainer = $Panel
@onready var cancel_button: Buttona = %CancelButton


func _ready() -> void:
	hide()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		unpopup()
	
	if viewport.gui_get_focus_owner():
		return
	if event.is_action_pressed("ui_down") or event.is_action_pressed("ui_up") or event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right") or event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_focus_next"):
		cancel_button.grab_focus()


func popup() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT
	show()
	refresh_tween()
	tween.tween_property(panel, "modulate:a", 1.0, (1.0 - panel.modulate.a) * animation_duration_popup)
	cancel_button.grab_focus()

func unpopup() -> void:
	if viewport.gui_get_focus_owner():
		viewport.gui_get_focus_owner().release_focus()
	
	refresh_tween()
	tween.tween_property(panel, "modulate:a", 0.0, panel.modulate.a * animation_duration_unpopup)
	await tween.finished
	hide()
	process_mode = Node.PROCESS_MODE_DISABLED


func refresh_tween() -> void:
	if tween:
		tween.kill()
	tween = create_tween()


func _on_cancel_button_pressed() -> void:
	unpopup()
