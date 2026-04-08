class_name ObjectManager extends Node
const DEBUG_NAME : String = "[b][ObjectManager][/b] "

static var instance : ObjectManager = null

enum ObjectType {WORKER,NECTAR,POLLEN}
static var spawned_objects : Node

static var worker_prefab = preload("res://Scenes/worker_bee.tscn")
static var nectar_prefab = preload("res://Scenes/nectar.tscn")
static var pollen_prefab = preload("res://Scenes/pollen.tscn")


func _enter_tree() -> void:
	instance = self
	spawned_objects = $SubViewportContainer/SubViewport/SpawnedObjects

static func create_worker() -> WorkerBee:
	var _new_worker = worker_prefab.instantiate()
	spawned_objects.add_child(_new_worker)
	return _new_worker

static func create_nectar() -> Nectar:
	var _new_nectar = nectar_prefab.instantiate()
	spawned_objects.add_child(_new_nectar)
	return _new_nectar

static func create_pollen() -> Pollen:
	var _new_pollen = pollen_prefab.instantiate()
	spawned_objects.add_child(_new_pollen)
	return _new_pollen


static func create_object(_type:ObjectType) -> Node2D:
	match _type:
		ObjectType.WORKER:
			return create_worker()
		ObjectType.NECTAR:
			return create_nectar()
		ObjectType.POLLEN:
			return create_pollen()
	
	print_rich(DEBUG_NAME,"CreateObject > [color=red]Bad object type recieved, cancelling.")
	return null
