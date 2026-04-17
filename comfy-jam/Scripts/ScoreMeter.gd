class_name ScoreMeter extends Node
const DEBUG_NAME : String = "[b][ScoreMeter][/b] "
static var instance : ScoreMeter = null

@export var larvae_score : int = 1
@export var nectar_score : int = 2
@export var pollen_score : int = 2
@export var royal_jelly_score : int = 2
@export var worker_score : int = 8
@export var honey_score : int = 15

var score_hex_parent : Control = null 
var odd_score_prefab : Control = null
var even_score_prefab : Control = null 

@export_category("READ ONLY")
@export var current_score : float = 0 :
	get: return current_score
	set(value):
		if value >= current_score_capacity:
			var _leftover = 0
			_leftover = value 
			while _leftover >= current_score_capacity:
				_leftover -= current_score_capacity
				current_score_hex.value = 44
				current_score_hex = add_score_hex()
				current_score_capacity = starting_score_capacity * (score_hexes.size() * 0.75)
				#current_score_hex.max_value = current_score_capacity
			current_score = clamp(_leftover,0,current_score_capacity)
		else:
			current_score = value
		current_score_hex.value = remap(current_score,0,current_score_capacity,18,44)


@export var score_hexes : Array[Control] = []

var current_score_hex : TextureProgressBar = null
var current_score_capacity : float = 0

var starting_score_capacity : float = 12

func _enter_tree() -> void:
	instance = self

func _ready() -> void:
	score_hex_parent = $ScoreHexParent
	even_score_prefab = $ScoreHexParent/EvenScoreHexHolder
	odd_score_prefab = $ScoreHexParent/OddScoreHex
	
	current_score_hex = add_score_hex()
	current_score_capacity = starting_score_capacity 
	
	
	#test()
#
#func test() -> void:
	#while (true):
		#await get_tree().create_timer(2).timeout
		#current_score += 6
	##await get_tree().create_timer(2).timeout
	##current_score += 6
	##await get_tree().create_timer(2).timeout
	##current_score += 6
	##await get_tree().create_timer(2).timeout
	##current_score += 6

func add_score_hex() -> TextureProgressBar:
	var _new_score_hex : TextureProgressBar = null
	var _prefab : Control = even_score_prefab if score_hexes.size() % 2 == 0 else odd_score_prefab
	
	_prefab = _prefab.duplicate()
	score_hex_parent.add_child(_prefab)
	
	_new_score_hex = _prefab.get_child(1).get_child(0) if score_hexes.size() % 2 == 0 else _prefab.get_child(0)
	_new_score_hex.value = 18
	score_hexes.append(_new_score_hex)
	
	_prefab.visible = true
	
	return _new_score_hex


static func larvae_scored() -> void:
	instance.current_score += instance.larvae_score
static func nectar_scored() -> void:
	instance.current_score += instance.nectar_score
static func pollen_scored() -> void:
	instance.current_score += instance.pollen_score
static func royal_jelly_scored() -> void:
	instance.current_score += instance.royal_jelly_score
static func worker_scored() -> void:
	instance.current_score += instance.worker_score
static func honey_scored() -> void:
	instance.current_score += instance.honey_score
