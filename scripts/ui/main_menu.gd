extends ScreenManager


@onready var title_screen: Screen = $TitleScreen
@onready var settings_screen: Screen = $SettingsScreen
@onready var credits_screen: Screen = $CreditsScreen


func _ready() -> void:
	super()
	
	main_screen = title_screen
	current_screen = title_screen


func _on_settings_button_pressed() -> void:
	switch_screen(settings_screen)

func _on_credits_button_pressed() -> void:
	switch_screen(credits_screen)

func _on_back_button_pressed() -> void:
	switch_screen(title_screen)
