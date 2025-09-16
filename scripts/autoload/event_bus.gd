extends Node


var player: Player


@warning_ignore("unused_signal") signal player_class_changed(new_value: String)
@warning_ignore("unused_signal") signal player_hp_changed(new_value: float, max_value: float)
@warning_ignore("unused_signal") signal player_weapon_changed(new_value: String)
@warning_ignore("unused_signal") signal player_mag_changed(new_value: int, max_value: int)
@warning_ignore("unused_signal") signal player_blood_changed(new_value: float, max_value: float)
@warning_ignore("unused_signal") signal player_hit(damage: float)
@warning_ignore("unused_signal") signal player_died
