extends Node


const RANDOFACTO: float = 0.1
const RANDOFACTO_DOUBLE: float = 0.2
const RANDOFACTO_SUBTLE: float = 0.03
enum RANDO_TYPES {
	NONE,
	SUBTLE,
	NORMAL,
	DOUBLE
}

const SAVE_PATH: String = "user://"

const FILE_UIDS: Dictionary[String, Variant] = {
	# SCENES
		# objects
	"bullet_scene": "uid://durccheqs6y0n",
	"bloodshot_scene": "uid://b4l7nhavg53cx",
		# vfx
	"blood_splatter_scene": "uid://cwqe7churtxrv",
	"blood_splatter_double_scene": "uid://b8w8gmjbvpced",
	"blood_explosion_scene": "uid://cs6dxwtk5651p",
	"muzzle_flash_scene": "uid://dtj76lgbo4ydn",
	"blood_splash_scene": "uid://c5g8ji3vl07fb",
	"dirt_splatter_scene": "uid://48ojgreyybe",
	"blood_stain_scene": "uid://mg1wvhjyn4p6",
	"blood_pool_scene": "uid://1twhq540r50",
		# ui
	"death_screen_scene": "uid://bomjpnrcspvgr",
		# ui
	"bloodslash1": "uid://lubkpi5hn26h",
	"bloodsplash2": "uid://bvsm1u4002f13",
	"bloodsplash_heavy": "uid://bvhasb18q6g3h",
	"bloodsplat": "uid://c4ueci36j340x",
	"bloodspray": "uid://1c4ggx8hfhuv",
		# sfx
	"gunshot_gun_sound_scene": "uid://cu8jx5g44exkl",
	"gunshot_machinegun_sound_scene": "uid://cem6wtki1g5bc",
	"gunshot_shotgun_sound_scene": "uid://yxsstnq3w53u",
	"impact_sound_scene": "uid://bmyckr4h84cif",
	"player_death_sound_scene": "uid://cu4b0m5pyx8sp",
	"zombie_attack_vocal_scene": "uid://b3nuqmybq5ogg",
	"zombie_pain_vocal_scene": "uid://cw7ps6bat76hc",
	"zombie_death_sound_scene": "uid://b7xaql1uurgkv",
	"click_sound_scene": "uid://dbjd5elpu7hmv",
	"back_sound_scene": "uid://ue70psdbmej7",
	
	# RESOURCES
		# spriteframes
	"zombie_norm1_spriteframes": "uid://w11jkih6lm7d",
	"zombie_norm2_spriteframes": "uid://3e86pvmlvh4j",
	"zombie_brawler1_spriteframes": "uid://0d3d8osuw42l",
	"zombie_brawler2_spriteframes": "uid://bvwf6h3qnn4f5",
	"zombie_gunner1_spriteframes": "uid://yysv60ig3y48",
	"zombie_gunner2_spriteframes": "uid://dvm80rvjyhma5",
	
	# SPRITES
		# weapons
	"weapon_tex_gun": "uid://bygmehm306uvm",
	"weapon_tex_machinegun": "uid://ds5ibso7vge53",
	"weapon_tex_shotgun": "uid://cohyjtj6jsj5q",
	
	# AUDIO
		# walk
	"walk_sound1": "uid://kednpx5gs5h7",
	"walk_sound2": "uid://qc6c8cpu54go",
	"walk_sound3": "uid://da8606cblf0gj",
	"walk_sound4": "uid://bjvowyof5cws6",
	"walk_sound5": "uid://dpruydp3jfkxp",
		# run
	"run_sound1": "uid://5os47blyhf70",
	"run_sound2": "uid://dvpt6w4h1yv2r",
	"run_sound3": "uid://calr2wkom20op",
	"run_sound4": "uid://3qwqetihfy1u",
	"run_sound5": "uid://dywhy053gcjbj",
		# reload
	"reload_start_sound_gun": "uid://bscw6y0xikje0",
	"reload_end_sound_gun": "uid://d4f1s3i8cnmrt",
	"reload_start_sound_machinegun": "uid://gxg8ovqmbids",
	"reload_end_sound_machinegun": "uid://del2kh7bw5s0f",
	"reload_start_sound_shotgun": "uid://upcboyrdmoyp",
	"reload_end_sound_shotgun": "uid://bclgxu6kam3pv",
		# impact
	"impact_sound1": "uid://davclf3asyvk2",
	"impact_sound2": "uid://cgm5hq3fgnsqj",
	"impact_sound3": "uid://ct7m75abpnp1d",
	"impact_sound4": "uid://b1gc822rs32do",
		# dash
	"dash_sound1": "uid://ds52cwm3qnpvo",
	"dash_sound2": "uid://cf762a25jx3k3",
	"dash_sound3": "uid://3v6d3mtw22lh",
		# dash slash
	"dash_slash_sound1": "uid://ddcmhefm1gy4e",
	"dash_slash_sound2": "uid://cax3xwhs1sxgy",
	"dash_slash_sound3": "uid://8sbp36wdxayr",
	"dash_slash_sound4": "uid://88oy2enuaxig",
		# player death
	"player_death_sounds": [
		"uid://bs216n52cey52",
		"uid://bpq0iojc2hlg3"
	],
		# zombie alert
	"zombie_alert_vocals": [
		"uid://cmca20fbh8ejt",
		"uid://d3qlmyxwc6xvm",
		"uid://dyjju3rsqqf6x"
	],
		# zombie attack
	"zombie_attack_vocals": [
		"uid://cw7umcy35ry1i",
		"uid://dkk8ovcdl6y3d",
		"uid://dmqntapxo2nbu",
		"uid://buvuo6w8yxbt7",
		"uid://dc8ijwh5pkxqq",
		"uid://ct1u2yubgvfu0",
		"uid://qk1flq5555we"
	],
		# zombie pain
	"zombie_pain_vocals": [
		"uid://cclei48vh714e",
		"uid://smytsa1dqe1r",
		"uid://ccp6doifgepe0",
		"uid://b8kc7lr4o3qey",
		"uid://duwcvl845s5up",
		"uid://3vmyd6l2hj1f",
		"uid://c28gnsmn82u3u",
		"uid://cbbniiuksa6d2",
		"uid://daxymhadjpyoe",
		"uid://b70mvlnpke122",
		"uid://dt6o8agubntej",
	],
		# zombie death
	"zombie_death_sounds": [
		"uid://cineolo1hjekt",
		"uid://b3rmgymbsv6xr",
		"uid://7dskehswi0xx",
		"uid://bx1sc8w107d4p"
	]
}


const ZOMBIE_ALERT_VOCALS: Array[AudioStreamWAV] = [
	preload(FILE_UIDS.zombie_alert_vocals[0]),
	preload(FILE_UIDS.zombie_alert_vocals[1]),
	preload(FILE_UIDS.zombie_alert_vocals[2])
]

const ZOMBIE_ATTACK_VOCALS: Array[AudioStreamWAV] = [
	preload(FILE_UIDS.zombie_attack_vocals[0]),
	preload(FILE_UIDS.zombie_attack_vocals[1]),
	preload(FILE_UIDS.zombie_attack_vocals[2]),
	preload(FILE_UIDS.zombie_attack_vocals[3]),
	preload(FILE_UIDS.zombie_attack_vocals[4]),
	preload(FILE_UIDS.zombie_attack_vocals[5]),
	preload(FILE_UIDS.zombie_attack_vocals[6])
]

const ZOMBIE_PAIN_VOCALS: Array[AudioStreamWAV] = [
	preload(FILE_UIDS.zombie_pain_vocals[0]),
	preload(FILE_UIDS.zombie_pain_vocals[1]),
	preload(FILE_UIDS.zombie_pain_vocals[2]),
	preload(FILE_UIDS.zombie_pain_vocals[3]),
	preload(FILE_UIDS.zombie_pain_vocals[4]),
	preload(FILE_UIDS.zombie_pain_vocals[5]),
	preload(FILE_UIDS.zombie_pain_vocals[6]),
	preload(FILE_UIDS.zombie_pain_vocals[7]),
	preload(FILE_UIDS.zombie_pain_vocals[8]),
	preload(FILE_UIDS.zombie_pain_vocals[9]),
	preload(FILE_UIDS.zombie_pain_vocals[10])
]

const ZOMBIE_DEATH_SOUNDS: Array[AudioStreamWAV] = [
	preload(FILE_UIDS.zombie_death_sounds[0]),
	preload(FILE_UIDS.zombie_death_sounds[1]),
	preload(FILE_UIDS.zombie_death_sounds[2]),
	preload(FILE_UIDS.zombie_death_sounds[3])
]


func _ready() -> void:
	randomize()
