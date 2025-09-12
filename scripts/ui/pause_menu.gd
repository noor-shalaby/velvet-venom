extends CanvasLayer


@export var animation_duration_pause: float = 0.2
@export var animation_duration_unpause: float = 0.3
@export var screen_transition_duration: float = 0.2
@export var tween_trans: Tween.TransitionType
@export var tween_ease: Tween.EaseType

@onready var scene_tree: SceneTree = get_tree()
@onready var viewport: Viewport = get_viewport()
@onready var viewport_visible_rect: Rect2 = viewport.get_visible_rect()
@onready var dim: PanelContainer = $Dim
@onready var resume_button: Buttona = %ResumeButton
@onready var settings_screen: Screen = $SettingsScreen
@onready var restart_popup: CanvasLayer = $RestartPopup
@onready var main_menu_popup: CanvasLayer = $MainMenuPopup
@onready var quit_popup: CanvasLayer = $QuitPopup

var tween: Tween
var previous_screen: Screen = null
@onready var current_screen: Screen = null


func _ready() -> void:
	hide()
	dim.modulate.a = 0.0


func _input(event: InputEvent) -> void:
	if restart_popup.visible or main_menu_popup.visible or quit_popup.visible:
		return
	
	if event.is_action_pressed("pause"):
		match current_screen:
			null:
				if not scene_tree.paused:
					pause()
				else:
					unpause()
			settings_screen:
				if Settings.audio:
					AudioManager.play_oneshot(AudioManager.BACK_SOUND_SCENE)
				switch_screen()
	
	if viewport.gui_get_focus_owner() or not scene_tree.paused:
		return
	if event.is_action_pressed("ui_down") or event.is_action_pressed("ui_up") or event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right") or event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_focus_next"):
		if current_screen:
			current_screen.init_focus_node.grab_focus()
		else:
			resume_button.grab_focus()


func pause() -> void:
	if not EventBus.player:
		return
	
	scene_tree.paused = true
	
	if Settings.audio:
		AudioManager.play_oneshot()
	
	show()
	refresh_tween()
	tween.tween_property(dim, "modulate:a", 1.0, (1.0 - dim.modulate.a) * animation_duration_pause)
	
	resume_button.grab_focus()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func unpause() -> void:
	if Settings.audio:
		AudioManager.play_oneshot(AudioManager.BACK_SOUND_SCENE)
	
	if viewport.gui_get_focus_owner():
		viewport.gui_get_focus_owner().release_focus()
	
	refresh_tween()
	tween.tween_property(dim, "modulate:a", 0.0, dim.modulate.a * animation_duration_unpause)
	await tween.finished
	hide()
	
	scene_tree.paused = false
	
	if Settings.gameplay_mouse_capture:
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED

func refresh_tween() -> void:
	if tween:
		tween.kill()
	tween = create_tween()


func switch_screen(new_screen: Control = null) -> void:
	if new_screen == current_screen:
		return
	
	if viewport.gui_get_focus_owner():
		viewport.gui_get_focus_owner().release_focus()
	
	var _tween: Tween = create_tween().set_parallel(true).set_trans(tween_trans).set_ease(tween_ease)
	var current_screen_target_y: float = -viewport_visible_rect.size.y
	var new_screen_initial_y: float = viewport_visible_rect.size.y
	if new_screen == null:
		current_screen_target_y *= -1.0
		new_screen_initial_y *= -1.0
	# Slide out current screen
	if current_screen:
		_tween.tween_property(current_screen, "position:y", current_screen_target_y, screen_transition_duration / 2)
		current_screen.process_mode = Node.PROCESS_MODE_DISABLED
	
	# Slide in new screen
	if new_screen:
		new_screen.show()
		new_screen.position.y = new_screen_initial_y
		_tween.tween_property(new_screen, "position:y", 0, screen_transition_duration / 2)
	
	previous_screen = current_screen
	current_screen = null
	await _tween.finished
	current_screen = new_screen
	if previous_screen:
		previous_screen.hide()
	if current_screen:
		current_screen.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		resume_button.grab_focus()


func _on_resume_button_pressed() -> void:
	unpause()

func _on_settings_button_pressed() -> void:
	switch_screen(settings_screen)

func _on_back_button_pressed() -> void:
	switch_screen()
