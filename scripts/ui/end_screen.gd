extends ScreenManager


@onready var victory_screen: Screen = $VictoryScreen
@onready var credits_screen: Screen = $CreditsScreen


func _ready() -> void:
	super()
	
	main_screen = victory_screen
	current_screen = victory_screen


func _on_credits_button_pressed() -> void:
	switch_screen(credits_screen)

func _on_back_button_pressed() -> void:
	switch_screen(victory_screen)
