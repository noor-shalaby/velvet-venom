extends Control


@export var screen_transition_duration: float = 0.4
@export var tween_trans: Tween.TransitionType
@export var tween_ease: Tween.EaseType


@onready var title_screen: Screen = $TitleScreen
@onready var settings_screen: Screen = $SettingsScreen
@onready var credits_screen: Screen = $CreditsScreen
@onready var blood_particles: CPUParticles2D = $BloodParticles
@onready var play_button: Buttona = %PlayButton

var previous_screen: Screen = null
@onready var current_screen: Screen = title_screen


@onready var viewport: Viewport = get_viewport()
@onready var viewport_visible_rect: Rect2 = viewport.get_visible_rect()


func _ready() -> void:
	setup_particles()
	if Settings.audio and Settings.music:
		AudioManager.play_ambient()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and current_screen and current_screen != title_screen:
		switch_screen(title_screen)
		if Settings.audio:
			AudioManager.play_oneshot(AudioManager.BACK_SOUND_SCENE)
	
	if viewport.gui_get_focus_owner():
		return
	if event.is_action_pressed("ui_down") or event.is_action_pressed("ui_up") or event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right") or event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_focus_next"):
		current_screen.init_focus_node.grab_focus()


func switch_screen(new_screen: Control = null) -> void:
	if new_screen == current_screen:
		return
	
	if viewport.gui_get_focus_owner():
		viewport.gui_get_focus_owner().release_focus()
	
	var tween: Tween = create_tween().set_parallel(true).set_trans(tween_trans).set_ease(tween_ease)
	var current_screen_target_y: float = -viewport_visible_rect.size.y
	var new_screen_initial_y: float = viewport_visible_rect.size.y
	if new_screen == title_screen:
		current_screen_target_y *= -1.0
		new_screen_initial_y *= -1.0
	# Slide out current screen
	if current_screen:
		tween.tween_property(current_screen, "position:y", current_screen_target_y, screen_transition_duration / 2)
		current_screen.process_mode = Node.PROCESS_MODE_DISABLED
	
	# Slide in new screen
	if new_screen:
		new_screen.show()
		new_screen.position.y = new_screen_initial_y
		tween.tween_property(new_screen, "position:y", 0, screen_transition_duration / 2)
	
	previous_screen = current_screen
	current_screen = null
	await tween.finished
	current_screen = new_screen
	if previous_screen:
		previous_screen.hide()
	if current_screen:
		current_screen.process_mode = Node.PROCESS_MODE_INHERIT


func setup_particles() -> void:
	if blood_particles:
		blood_particles.emission_rect_extents.x = size.x / 2.0
		blood_particles.position = Vector2(size.x / 2, size.y + 8.0)
		blood_particles.amount = int((size.x / 2.0) / 30)


func _on_settings_button_pressed() -> void:
	switch_screen(settings_screen)

func _on_credits_button_pressed() -> void:
	switch_screen(credits_screen)

func _on_back_button_pressed() -> void:
	switch_screen(title_screen)


func _on_resized() -> void:
	setup_particles()
