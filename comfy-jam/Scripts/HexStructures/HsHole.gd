class_name HexStructureHole extends HexStructure
func _debug_name() -> String:
	return "[b][" + get_parent().name + "/HsHole][/b] "

var sprite : Sprite2D = null


@export var returnable_amount : int = 1
@export var returnable_candidates : Array[ObjectManager.ObjectType] = []

@export var startup_time : float = 1
@export var wrapup_time : float = 3

@export var forage_time : Vector2 = Vector2(5,10)

@export var speed_multiplier : float = 1

@export_category("READ ONLY")

@export var active : bool = false

@export var _returnables : Array[Node2D] = []

func _setup() -> void:
	print_rich(DEBUG_NAME,"Setup > Yep!")
	sprite = $Sprite2D
	
	max_workers = 1
	

func object_dropped_here(_object:Node2D) -> void:
	super(_object)
	
	if !active && assigned_workers == 1:
		print_rich(DEBUG_NAME,"ObjectDroppedHere > Worker assigned, beginning to forage!")
		sprite.visible = true
		foraging()




func foraging() -> void:
	active = true
	while (active):
		
		await start_forage()
		
		await get_tree().create_timer(randf_range(forage_time.x,forage_time.y) * speed_multiplier).timeout
		
		await finish_forage()
		
		var _chosen_returnables : Array[ObjectManager.ObjectType]
		if !returnable_candidates.is_empty():
			for i in returnable_amount:
				_chosen_returnables.append(returnable_candidates.pick_random())
		
		#Here is where we check if there are other hexes that can grab the thing
		
		var _new_object : Node2D = null
		while !_chosen_returnables.is_empty():
			# Create an object from the last chosen returnable type
			_new_object = ObjectManager.create_object(_chosen_returnables.pop_back())
			_new_object.global_position = self.global_position
			print_rich(DEBUG_NAME,"Foraging > Popped out '"+_new_object.name+"'! Waiting for player to grab...")
			await _new_object.on_move



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
