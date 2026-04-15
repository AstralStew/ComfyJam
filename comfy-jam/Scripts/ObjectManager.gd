class_name ObjectManager extends Node
const DEBUG_NAME : String = "[b][ObjectManager][/b] "

static var instance : ObjectManager = null

enum ObjectType {LARVAE,WORKER,NECTAR,POLLEN,ROYAL_JELLY}
static var spawned_objects : Node

static var larvae_prefab = preload("res://Scenes/larvae.tscn")
static var worker_prefab = preload("res://Scenes/worker_bee.tscn")

static var nectar_prefab = preload("res://Scenes/nectar.tscn")
static var pollen_prefab = preload("res://Scenes/pollen.tscn")
static var royal_jelly_prefab = preload("res://Scenes/royal_jelly.tscn")


func _enter_tree() -> void:
	instance = self
	spawned_objects = $"../SubViewportContainer/SubViewport/SpawnedObjects"
	print_rich(DEBUG_NAME,"EnterTree > SpawnedObjects = "+spawned_objects.name)
	

static func create_larvae(_position:Vector2,_auto_fall:bool=false) -> Larvae:
	var _new_larvae : Larvae = larvae_prefab.instantiate()
	_new_larvae.name = "Larvae"
	_new_larvae.add_to_group("Larvae")
	_new_larvae.fall_on_setup = _auto_fall
	spawned_objects.add_child(_new_larvae)
	#_new_larvae.setup()
	_new_larvae.global_position = _position - _new_larvae._draggable.position
	return _new_larvae

static func create_worker(_position:Vector2,_auto_fall:bool=false) -> WorkerBee:
	var _new_worker : WorkerBee = worker_prefab.instantiate()
	_new_worker.name = "WorkerBee"
	_new_worker.add_to_group("Workers")
	_new_worker.fall_on_setup = _auto_fall
	spawned_objects.add_child(_new_worker)
	#_new_worker.setup()
	_new_worker.global_position = _position - _new_worker._draggable.position
	return _new_worker

static func create_nectar(_position:Vector2,_auto_fall:bool=false) -> Nectar:
	var _new_nectar : Nectar = nectar_prefab.instantiate()
	_new_nectar.name = "Nectar"
	_new_nectar.add_to_group("Nectar")
	_new_nectar.fall_on_setup = _auto_fall
	spawned_objects.add_child(_new_nectar)
	#_new_nectar.setup()
	_new_nectar.global_position = _position - _new_nectar._draggable.position
	return _new_nectar

static func create_pollen(_position:Vector2,_auto_fall:bool=false) -> Pollen:
	var _new_pollen : Pollen = pollen_prefab.instantiate()
	_new_pollen.name = "Pollen"
	_new_pollen.add_to_group("Pollen")
	_new_pollen.fall_on_setup = _auto_fall
	spawned_objects.add_child(_new_pollen)
	#_new_pollen.setup()
	_new_pollen.global_position = _position - _new_pollen._draggable.position
	return _new_pollen

static func create_royal_jelly(_position:Vector2,_auto_fall:bool=false) -> RoyalJelly:
	var _new_jelly : RoyalJelly = royal_jelly_prefab.instantiate()
	_new_jelly.name = "RoyalJelly"
	_new_jelly.add_to_group("RoyalJelly")
	_new_jelly.fall_on_setup = _auto_fall
	spawned_objects.add_child(_new_jelly)
	#_new_jelly.setup()
	_new_jelly.global_position = _position - _new_jelly._draggable.position
	return _new_jelly

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
	
	return false
