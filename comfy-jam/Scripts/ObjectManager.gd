class_name ObjectManager extends Node
const DEBUG_NAME : String = "[b][ObjectManager][/b] "

static var instance : ObjectManager = null

enum ObjectType {WORKER,NECTAR,POLLEN,ROYAL_JELLY}
static var spawned_objects : Node

static var worker_prefab = preload("res://Scenes/worker_bee.tscn")
static var nectar_prefab = preload("res://Scenes/nectar.tscn")
static var pollen_prefab = preload("res://Scenes/pollen.tscn")
static var royal_jelly_prefab = preload("res://Scenes/royal_jelly.tscn")


func _enter_tree() -> void:
	instance = self
	spawned_objects = $"../SubViewportContainer/SubViewport/SpawnedObjects"
	print_rich(DEBUG_NAME,"EnterTree > SpawnedObjects = "+spawned_objects.name)
	

static func create_worker() -> WorkerBee:
	var _new_worker = worker_prefab.instantiate()
	_new_worker.name = "WorkerBee"
	spawned_objects.add_child(_new_worker)
	return _new_worker

static func create_nectar() -> Nectar:
	var _new_nectar = nectar_prefab.instantiate()
	_new_nectar.name = "Nectar"
	spawned_objects.add_child(_new_nectar)
	return _new_nectar

static func create_pollen() -> Pollen:
	var _new_pollen = pollen_prefab.instantiate()
	_new_pollen.name = "Pollen"
	spawned_objects.add_child(_new_pollen)
	return _new_pollen

static func create_royal_jelly() -> RoyalJelly:
	var _new_jelly = royal_jelly_prefab.instantiate()
	_new_jelly.name = "RoyalJelly"
	spawned_objects.add_child(_new_jelly)
	return _new_jelly

static func create_object(_type:ObjectType) -> Node2D:
	match _type:
		ObjectType.WORKER:
			return create_worker()
		ObjectType.NECTAR:
			return create_nectar()
		ObjectType.POLLEN:
			return create_pollen()
		ObjectType.ROYAL_JELLY:
			return create_royal_jelly()
	
	print_rich(DEBUG_NAME,"CreateObject > [color=red]Bad object type recieved, cancelling.")
	return null
