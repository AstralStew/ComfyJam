class_name ObjectManager extends Node
const DEBUG_NAME : String = "[b][ObjectManager][/b] "

static var instance : ObjectManager = null

enum ObjectType {LARVAE,WORKER,NECTAR,POLLEN,ROYAL_JELLY,HONEY}
static var spawned_objects : Node

static var larvae_prefab = preload("res://Scenes/larvae.tscn")
static var worker_prefab = preload("res://Scenes/worker_bee.tscn")

static var nectar_prefab = preload("res://Scenes/nectar.tscn")
static var pollen_prefab = preload("res://Scenes/pollen.tscn")
static var royal_jelly_prefab = preload("res://Scenes/royal_jelly.tscn")
static var honey_prefab = preload("res://Scenes/honey.tscn")

static var free_stand_move_position : Vector2 = Vector2(640,0)

func reset() -> void:
	instance = self
	spawned_objects = $"../SubViewportContainer/SubViewport/HiveNodes/SpawnedObjects"

func _enter_tree() -> void:
	reset()
	
	print_rich(DEBUG_NAME,"EnterTree > SpawnedObjects = "+spawned_objects.name)

func _ready() -> void:
	for i in HiveManager.upgrade_starting_number_of_larvae:
		var _new_larvae = create_larvae(Vector2(randi_range(100,540),600),true)
		_new_larvae.free_standing = true
		_new_larvae.add_to_group("Larvae")
	
	for i in HiveManager.upgrade_starting_number_of_workers:
		var _new_worker = create_worker(Vector2(randi_range(100,540),600),true)
		_new_worker.free_standing = true
		_new_worker.add_to_group("Workers")
	
	for i in HiveManager.upgrade_starting_number_of_nectar:
		var _new_nectar = create_nectar(Vector2(randi_range(100,540),600),true)
		_new_nectar.free_standing = true
		_new_nectar.add_to_group("Nectar")
	
	for i in HiveManager.upgrade_starting_number_of_pollen:
		var _new_pollen = create_pollen(Vector2(randi_range(100,540),600),true)
		_new_pollen.free_standing = true
		_new_pollen.add_to_group("Pollen")
	
	for i in HiveManager.upgrade_starting_number_of_royal_jelly:
		var _new_royal_jelly = create_royal_jelly(Vector2(randi_range(100,540),600),true)
		_new_royal_jelly.free_standing = true
		_new_royal_jelly.add_to_group("RoyalJelly")
	
	for i in HiveManager.upgrade_starting_number_of_honey:
		var _new_honey = create_honey(Vector2(randi_range(100,540),600),true)
		_new_honey.free_standing = true
		_new_honey.add_to_group("Honey")
	


static func create_larvae(_position:Vector2,_auto_fall:bool=false) -> Larvae:
	var _new_larvae : Larvae = larvae_prefab.instantiate()
	_new_larvae.name = "Larvae"
	#_new_larvae.add_to_group("Larvae")
	_new_larvae.fall_on_setup = _auto_fall
	spawned_objects.add_child(_new_larvae)
	_new_larvae.setup()
	_new_larvae.global_position = _position - _new_larvae._draggable.position
	return _new_larvae

static func create_worker(_position:Vector2,_auto_fall:bool=false) -> WorkerBee:
	var _new_worker : WorkerBee = worker_prefab.instantiate()
	_new_worker.name = "WorkerBee"
	#_new_worker.add_to_group("Workers")
	_new_worker.fall_on_setup = _auto_fall
	spawned_objects.add_child(_new_worker)
	_new_worker.setup()
	_new_worker.global_position = _position - _new_worker._draggable.position
	return _new_worker

static func create_nectar(_position:Vector2,_auto_fall:bool=false) -> Nectar:
	var _new_nectar : Nectar = nectar_prefab.instantiate()
	_new_nectar.name = "Nectar"
	#_new_nectar.add_to_group("Nectar")
	_new_nectar.fall_on_setup = _auto_fall
	spawned_objects.add_child(_new_nectar)
	_new_nectar.setup()
	_new_nectar.global_position = _position - _new_nectar._draggable.position
	return _new_nectar

static func create_pollen(_position:Vector2,_auto_fall:bool=false) -> Pollen:
	var _new_pollen : Pollen = pollen_prefab.instantiate()
	_new_pollen.name = "Pollen"
	#_new_pollen.add_to_group("Pollen")
	_new_pollen.fall_on_setup = _auto_fall
	spawned_objects.add_child(_new_pollen)
	_new_pollen.setup()
	_new_pollen.global_position = _position - _new_pollen._draggable.position
	return _new_pollen

static func create_royal_jelly(_position:Vector2,_auto_fall:bool=false) -> RoyalJelly:
	var _new_jelly : RoyalJelly = royal_jelly_prefab.instantiate()
	_new_jelly.name = "RoyalJelly"
	#_new_jelly.add_to_group("RoyalJelly")
	_new_jelly.fall_on_setup = _auto_fall
	spawned_objects.add_child(_new_jelly)
	_new_jelly.setup()
	_new_jelly.global_position = _position - _new_jelly._draggable.position
	return _new_jelly

static func create_honey(_position:Vector2,_auto_fall:bool=false) -> Honey:
	var _new_honey : Honey = honey_prefab.instantiate()
	_new_honey.name = "Honey"
	#_new_honey.add_to_group("Honey")
	_new_honey.fall_on_setup = _auto_fall
	spawned_objects.add_child(_new_honey)
	_new_honey.setup()
	_new_honey.global_position = _position - _new_honey._draggable.position
	return _new_honey

static func create_object(_type:ObjectType,_position:Vector2) -> Node2D:
	match _type:
		ObjectType.LARVAE:
			return create_larvae(_position)
		ObjectType.WORKER:
			return create_worker(_position)
		ObjectType.NECTAR:
			return create_nectar(_position)
		ObjectType.POLLEN:
			return create_pollen(_position)
		ObjectType.ROYAL_JELLY:
			return create_royal_jelly(_position)
		ObjectType.HONEY:
			return create_honey(_position)
	
	print_rich(DEBUG_NAME,"CreateObject > [color=red]Bad object type recieved, cancelling.")
	return null


static func move_and_destroy(_object:Node2D,_end_pos:Vector2,_duration:float=0.7) -> void:
	#_object.process_mode = Node.PROCESS_MODE_DISABLED
	_object.hide_outline()
	_object.set_script(null)
	for i in _object.get_child_count():
		if i > 0: _object.get_child(i).queue_free()
	await instance.get_tree().process_frame
	
	# Moving animation
	#var _sprite = _object.get_child(0)
	var _tween = instance.create_tween().set_parallel(true)#.set_ease(Tween.EASE_IN)
	_tween.tween_property(_object, "global_position", _end_pos, _duration)
	_tween.tween_property(_object, "scale", Vector2(0.5,0.5), _duration)
	_tween.tween_property(_object, "modulate", Color(1,1,1,0), _duration)
	await _tween.finished
	
	_object.queue_free()
	


static func free_stand_object(_object:Node2D) -> bool:
	if !check_if_object_is_ours:
		print_rich(DEBUG_NAME,"[color=red] FreeStandObject > ERROR, object '"+_object.name+"'is not one of ours! Returning false")
		return false
	if _object.free_standing:
		print_rich(DEBUG_NAME,"[color=orange] FreeStandObject > Object '"+_object.name+"'is already free standing! Returning false")
		return false
	
	var _old_object : Node2D
	if _object is WorkerBee:
		
		var _workers = instance.get_tree().get_nodes_in_group("Workers")
		while _workers.size() >= HiveManager.max_number_of_each_object - 1:
			print_rich(DEBUG_NAME,"FreeStandObject > Too many workers! Moving and destroying 1...")
			_workers.shuffle()
			_old_object = _workers.pop_back()
			_old_object.remove_from_group("Workers")
			move_and_destroy(_old_object,free_stand_move_position,1)
			ScoreMeter.worker_scored()
			await instance.get_tree().process_frame
		_object.add_to_group("Workers")
		_object.free_standing = true
		return true
	
	if _object is Larvae:
		var _larvaes = instance.get_tree().get_nodes_in_group("Larvae")
		while _larvaes.size() >= HiveManager.max_number_of_each_object - 1:
			print_rich(DEBUG_NAME,"FreeStandObject > Too many larvae! Moving and destroying 1...")
			_larvaes.shuffle()
			_old_object = _larvaes.pop_back()
			_old_object.remove_from_group("Larvae")
			move_and_destroy(_old_object,free_stand_move_position,1)
			ScoreMeter.larvae_scored()
			await instance.get_tree().process_frame
		_object.add_to_group("Larvae")
		_object.free_standing = true
		return true
	
	if _object is Nectar:
		var _nectars = instance.get_tree().get_nodes_in_group("Nectar")
		while _nectars.size() >= HiveManager.max_number_of_each_object - 1:
			print_rich(DEBUG_NAME,"FreeStandObject > Too many nectar! Moving and destroying 1...")
			_nectars.shuffle()
			_old_object = _nectars.pop_back()
			_old_object.remove_from_group("Nectar")
			move_and_destroy(_old_object,free_stand_move_position,1)
			ScoreMeter.nectar_scored()
			await instance.get_tree().process_frame
		_object.add_to_group("Nectar")
		_object.free_standing = true
		return true
	
	if _object is Pollen:
		var _pollens = instance.get_tree().get_nodes_in_group("Pollen")
		while _pollens.size() >= HiveManager.max_number_of_each_object - 1:
			print_rich(DEBUG_NAME,"FreeStandObject > Too many pollen! Moving and destroying 1...")
			_pollens.shuffle()
			_old_object = _pollens.pop_back()
			_old_object.remove_from_group("Pollen")
			move_and_destroy(_old_object,free_stand_move_position,1)
			ScoreMeter.pollen_scored()
			await instance.get_tree().process_frame
		_object.add_to_group("Pollen")
		_object.free_standing = true
		return true
	
	if _object is RoyalJelly:
		var _jellies = instance.get_tree().get_nodes_in_group("RoyalJelly")
		while _jellies.size() >= HiveManager.max_number_of_each_object - 1:
			print_rich(DEBUG_NAME,"FreeStandObject > Too many royal jellies! Moving and destroying 1...")
			_jellies.shuffle()
			_old_object = _jellies.pop_back()
			_old_object.remove_from_group("RoyalJelly")
			move_and_destroy(_old_object,free_stand_move_position,1)
			ScoreMeter.royal_jelly_scored()
			await instance.get_tree().process_frame
		_object.add_to_group("RoyalJelly")
		_object.free_standing = true
		return true
	
	if _object is Honey:
		var _honeys = instance.get_tree().get_nodes_in_group("Honey")
		while _honeys.size() >= HiveManager.max_number_of_each_object - 1:
			print_rich(DEBUG_NAME,"FreeStandObject > Too many honey! Moving and destroying 1...")
			_honeys.shuffle()
			_old_object = _honeys.pop_back()
			_old_object.remove_from_group("Honey")
			move_and_destroy(_old_object,free_stand_move_position,1)
			ScoreMeter.honey_scored()
			await instance.get_tree().process_frame
		_object.add_to_group("Honey")
		_object.free_standing = true
		return true
		
	push_error(DEBUG_NAME,"[color=red] FreeStandObject > ERROR, shouldn't get here! Returning false")
	return false

static func get_type_of_object(_object:Node2D) -> ObjectType:
	if _object is WorkerBee:
		return ObjectType.WORKER
	elif _object is Larvae:
		return ObjectType.LARVAE
	elif _object is Nectar:
		return ObjectType.NECTAR
	elif _object is Pollen:
		return ObjectType.POLLEN
	elif _object is RoyalJelly:
		return ObjectType.ROYAL_JELLY
	elif _object is Honey:
		return ObjectType.HONEY
	
	return -1

static func check_if_object_is_ours(_object:Node2D) -> bool:
	if _object is WorkerBee:
		return true
	elif _object is Larvae:
		return true
	elif _object is Nectar:
		return true
	elif _object is Pollen:
		return true
	elif _object is RoyalJelly:
		return true
	elif _object is Honey:
		return true
	
	return false
