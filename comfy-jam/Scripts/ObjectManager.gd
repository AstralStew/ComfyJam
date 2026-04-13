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
	spawned_objects.add_child(_new_larvae)
	_new_larvae._fall_on_setup = _auto_fall
	_new_larvae.setup()
	_new_larvae.global_position = _position - _new_larvae._draggable.position
	return _new_larvae

static func create_worker(_position:Vector2,_auto_fall:bool=false) -> WorkerBee:
	var _new_worker : WorkerBee = worker_prefab.instantiate()
	_new_worker.name = "WorkerBee"
	_new_worker.add_to_group("Workers")
	spawned_objects.add_child(_new_worker)
	_new_worker._fall_on_setup = _auto_fall
	_new_worker.setup()
	_new_worker.global_position = _position - _new_worker._draggable.position
	return _new_worker

static func create_nectar(_position:Vector2,_auto_fall:bool=false) -> Nectar:
	var _new_nectar : Nectar = nectar_prefab.instantiate()
	_new_nectar.name = "Nectar"
	_new_nectar.add_to_group("Nectar")
	spawned_objects.add_child(_new_nectar)
	_new_nectar._fall_on_setup = _auto_fall
	_new_nectar.setup()
	_new_nectar.global_position = _position - _new_nectar._draggable.position
	return _new_nectar

static func create_pollen(_position:Vector2,_auto_fall:bool=false) -> Pollen:
	var _new_pollen : Pollen = pollen_prefab.instantiate()
	_new_pollen.name = "Pollen"
	_new_pollen.add_to_group("Pollen")
	spawned_objects.add_child(_new_pollen)
	_new_pollen._fall_on_setup = _auto_fall
	_new_pollen.setup()
	_new_pollen.global_position = _position - _new_pollen._draggable.position
	return _new_pollen

static func create_royal_jelly(_position:Vector2,_auto_fall:bool=false) -> RoyalJelly:
	var _new_jelly : RoyalJelly = royal_jelly_prefab.instantiate()
	_new_jelly.name = "RoyalJelly"
	_new_jelly.add_to_group("RoyalJelly")
	spawned_objects.add_child(_new_jelly)
	_new_jelly._fall_on_setup = _auto_fall
	_new_jelly.setup()
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
