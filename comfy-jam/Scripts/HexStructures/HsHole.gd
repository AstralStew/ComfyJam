class_name HexStructureHole extends HexStructure
func _debug_name() -> String:
	return "[b][" + get_parent().name + "/HsHole][/b] "

var sprite : Sprite2D = null


@export var returnable_candidates : Array[ObjectManager.ObjectType] = []

@export var startup_time : float = 1
@export var wrapup_time : float = 3

@export var forage_time : Vector2 = Vector2(5,10)

@export var speed_multiplier : float = 1
@export var returnable_amount : float = 1

@export_category("READ ONLY")

@export var _returnables : Array[Node2D] = []

func _setup() -> void:
	print_rich(DEBUG_NAME,"Setup > ")
	sprite = $Sprite2D
	
	max_workers = 1
	
	foraging()


func foraging() -> void:
	while (assigned_workers > 0):
		
		await start_forage()
		
		await get_tree().create_timer(randf_range(forage_time.x,forage_time.y) * speed_multiplier).timeout
		
		await finish_forage()
		
		var _new_object : Node2D = null
		if !returnable_candidates.is_empty():
			for i in returnable_amount:
				_new_object = ObjectManager.create_object(returnable_candidates.pick_random())
				_new_object.global_position = self.global_position
				_returnables.append(_new_object)
				print_rich(DEBUG_NAME,"Foraging > Added '"+_new_object.name+"' to returnables...")
		
		
		#if !_returnables.is_empty():
			#_returnables = _new_returnables
			##for i in _returnables.size():
				##var _returnable = 
				#
			#
		
		
		while !_returnables.is_empty():
			await get_tree().process_frame
		

func start_forage() -> void:
	# Startup animation
	var _tween = create_tween().set_parallel(true)
	_tween.tween_property(sprite, "scale", Vector2(0.1,0.1), startup_time)
	_tween.tween_property(sprite, "modulate", Color(0,0,0,0), startup_time)
	await _tween.finished

func finish_forage() -> void:
	# Finish up animation
	var _tween = create_tween().set_parallel(true)
	_tween.tween_property(sprite, "scale", Vector2(0.445,0.445), wrapup_time)
	_tween.tween_property(sprite, "modulate", Color.WHITE, wrapup_time)
	await _tween.finished
