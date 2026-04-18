class_name ScoreMeter extends Control
const DEBUG_NAME : String = "[b][ScoreMeter][/b] "
static var instance : ScoreMeter = null

@export var score_added_scale_multiplier : float = 1.5
@export var score_added_scale_duration : float = 1

@export var larvae_score : int = 1
@export var nectar_score : int = 2
@export var pollen_score : int = 2
@export var royal_jelly_score : int = 2
@export var worker_score : int = 8
@export var honey_score : int = 15

var score_hex_parent : Control = null 
var odd_score_prefab : Control = null
var even_score_prefab : Control = null 


@export var _starting_scale : Vector2 = Vector2.ONE

@export_category("READ ONLY")
@export var meta_score : int = 0 :
	get: return meta_score
	set(value):
		print_rich(DEBUG_NAME,"MetaScore > Changing meta_score from "+str(meta_score)+" to "+str(value))
		if meta_score > value:
			current_score_hex = remove_score_hex()
		elif meta_score < value:
			var _current_score_hex_value = current_score_hex.value
			current_score_hex.value = 44
			current_score_hex = add_score_hex()
			current_score_hex.value = 18 #_current_score_hex_value
			current_score_capacity = current_score_capacity * 2
		
		meta_score = value
		
		if _score_added_tween: _score_added_tween.kill()
		_score_added_tween = create_tween().set_parallel().set_trans(Tween.TRANS_QUART)
		_score_added_tween.tween_property(instance,"scale",_starting_scale * score_added_scale_multiplier,score_added_scale_duration/2).set_ease(Tween.EASE_OUT)
		_score_added_tween.tween_property(instance,"scale",_starting_scale,score_added_scale_duration/2).set_ease(Tween.EASE_IN).set_delay(score_added_scale_duration/2)


@export var current_score : float = 0 :
	get: return current_score
	set(value):
		if value >= current_score_capacity:
			var _leftover = 0
			_leftover = value 
			while _leftover >= current_score_capacity:
				_leftover -= current_score_capacity
				#current_score_hex.value = 44
				#current_score_hex = add_score_hex()
				#current_score_capacity = current_score_capacity * 2 #starting_score_capacity * (score_hexes.size())
				meta_score += 1
				#current_score_hex.max_value = current_score_capacity
			current_score = clamp(_leftover,0,current_score_capacity)
		else:
			current_score = value
		current_score_hex.value = remap(current_score,0,current_score_capacity,18,44)
		
		if _score_added_tween: _score_added_tween.kill()
		_score_added_tween = create_tween().set_parallel().set_trans(Tween.TRANS_QUART)
		_score_added_tween.tween_property(instance,"scale",_starting_scale * score_added_scale_multiplier,score_added_scale_duration/2).set_ease(Tween.EASE_OUT)
		_score_added_tween.tween_property(instance,"scale",_starting_scale,score_added_scale_duration/2).set_ease(Tween.EASE_IN).set_delay(score_added_scale_duration/2)


@export var score_hexes : Array[Control] = []

var current_score_hex : TextureProgressBar = null
var current_score_capacity : float = 0

var starting_score_capacity : float = 20


var _score_added_tween : Tween = null


func _enter_tree() -> void:
	instance = self

func _ready() -> void:
	score_hex_parent = $ScoreHexParent
	even_score_prefab = $ScoreHexParent/EvenScoreHexHolder
	odd_score_prefab = $ScoreHexParent/OddScoreHex
	
	current_score_hex = add_score_hex()
	current_score_capacity = starting_score_capacity 
	
	_starting_scale = scale
	
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
	_new_score_hex.value = 17
	score_hexes.append(_new_score_hex)
	
	_prefab.visible = true
	
	return _new_score_hex


func remove_score_hex() -> TextureProgressBar:
	#var _last_score_hex : TextureProgressBar = null
	#var _prefab : Control = even_score_prefab if score_hexes.size() % 2 == 0 else odd_score_prefab
	
	#_prefab = _prefab.duplicate()
	#score_hex_parent.add_child(_prefab)
	if score_hexes.size() < 2:
		print_rich(DEBUG_NAME,"RemoveScoreHex > Not enough hexes left to remove! Cancelling")
		return null
	
	var _new_score_hex : TextureProgressBar = score_hexes[score_hexes.size() - 2] 
	_new_score_hex.value = current_score_hex.value
	score_hexes.pop_back().queue_free()
	
	return _new_score_hex


func adjust_meta_score(_amount:int) -> void:
	meta_score += _amount


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
	
static func royal_order_complete() -> void:
	instance.meta_score += 1
