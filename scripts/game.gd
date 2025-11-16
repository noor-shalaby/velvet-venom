extends Node2D


@export var next_level: String

enum MISSION_TYPES {
	CLEANSE
}
@export var mission_type: MISSION_TYPES = MISSION_TYPES.CLEANSE

@onready var scene_tree: SceneTree = get_tree()
@onready var zombies_node: Node2D = $Zombies
@onready var zombies: Array[Node] = zombies_node.get_children()
@onready var zombie_count_max: int = zombies_node.get_child_count()
@onready var zombie_count: int = zombie_count_max:
	set = set_zombie_count
func set_zombie_count(new_value: int) -> void:
	if mission_type != MISSION_TYPES.CLEANSE:
		return
	
	zombie_count = new_value
	EventBus.emit_signal("objective_progress_changed", "Cleanse", zombie_count_max - zombie_count, zombie_count_max)
	
	if zombie_count <= 0:
		await scene_tree.create_timer(2.0).timeout
		if next_level:
			SceneTransitioner.trans_to_scene(next_level)
		else:
			SceneTransitioner.trans_to_scene(Constants.FILE_UIDS.end_screen_scene)


func _ready() -> void:
	match mission_type:
		MISSION_TYPES.CLEANSE:
			EventBus.emit_signal("objective_progress_changed", "Cleanse", zombie_count_max - zombie_count, zombie_count_max)


func _on_zombies_child_exiting_tree(_node: Node) -> void:
	zombie_count -= 1
