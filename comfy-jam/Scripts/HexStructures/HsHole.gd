class_name HexStructureHole extends HexStructure
func _debug_name() -> String:
	return "[b][" + get_parent().name + "/HsHole][/b] "

var _sprite : AnimatedSprite2D = null

static var number_of_nectar_holes_global : int = 0
static var number_of_pollen_holes_global : int = 0

#@export var returnable_amount : int = 1
#@export var returnable_candidates : Array[ObjectManager.ObjectType] = []

@export var startup_time : float = 1
@export var wrapup_time : float = 3

@export var forage_time : Vector2 = Vector2(5,10)

@export_category("READ ONLY")

@export var speed_multiplier : float = 1



func _setup() -> void:
	super()
	
	print_rich(DEBUG_NAME,"Setup(Hole) > Yep!")
	_sprite = $BeeSprite
	_sprite.play("default")
	_sprite.flip_h = randi() % 1
	
	speed_multiplier = HiveManager.upgrade_hole_speed_multiplier * HiveManager.upgrade_global_speed_multiplier
	output_amount = HiveManager.upgrade_hole_output_number
	
	if number_of_nectar_holes_global > number_of_pollen_holes_global + 2:
		output_candidates.remove_at(output_candidates.find(ObjectManager.ObjectType.NECTAR))
	elif number_of_pollen_holes_global > number_of_nectar_holes_global + 2:
		output_candidates.remove_at(output_candidates.find(ObjectManager.ObjectType.POLLEN))
	else:
		output_candidates.remove_at(randi() % 1)
	
	if output_candidates[0] == ObjectManager.ObjectType.NECTAR:
		number_of_nectar_holes_global += 1
	else: number_of_pollen_holes_global += 1
	
	
	var _forage_sprites:Array[Node] = $Sky.get_children()
	_forage_sprites.shuffle()
	var _sprites_to_destroy:int = randi_range(3,5)
	for i in _sprites_to_destroy:
		if i < _sprites_to_destroy:
			_forage_sprites.pop_back().queue_free()
	
	for _forage_sprite in _forage_sprites:
		if output_candidates[0] == ObjectManager.ObjectType.POLLEN:
			_forage_sprite.region_rect = Rect2(15,93,45,37)
		else:
			_forage_sprite.region_rect = Rect2(244,100,40,28)
	
	
	max_workers = 1
	

#func worker_dropped_here(_worker:WorkerBee) -> bool:
	#if !super(_worker):
		## Worker was not used by base class, cancelling here
		#return false
	#
	## Activate foraging
	#if !active && assigned_workers == 1:
		#activate()
	#
	#return true

func activate() -> void:
	if active: return
	
	print_rich(DEBUG_NAME,"Activate > Activated, beginning to forage!")
	_sprite.visible = true
	active = true
	
	super()
	
	foraging()

func foraging() -> void:
	
	while (active):
		
		await start_forage()
		
		await get_tree().create_timer(randf_range(forage_time.x,forage_time.y) / speed_multiplier).timeout
		
		await finish_forage()
		
		add_object_to_output()
		output_object()
		
		await on_outputs_empty
		
		#print_rich("[color=pink] outputs are empty")
		
		
		
		#var _chosen_returnables : Array[ObjectManager.ObjectType]
		#if !returnable_candidates.is_empty():
			#for i in returnable_amount:
				#_chosen_returnables.append(returnable_candidates.pick_random())
		#
		##Here is where we check if there are other hexes that can grab the thing
		#
		#var _new_object : Node2D = null
		#while !_chosen_returnables.is_empty():
			## Create an object from the last chosen returnable type
			#_new_object = ObjectManager.create_object(_chosen_returnables.pop_back())
			#_new_object.global_position = self.global_position
			#print_rich(DEBUG_NAME,"Foraging > Popped out '"+_new_object.name+"'! Waiting for player to grab...")
			#await _new_object.on_move



func start_forage() -> void:
	# Startup animation
	var _tween = create_tween().set_parallel(true)
	_tween.tween_property(_sprite, "scale", Vector2(0.1,0.1), startup_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.tween_property(_sprite, "modulate", Color(0,0,0,0), startup_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await _tween.finished

func finish_forage() -> void:
	# Finish up animation
	var _tween = create_tween().set_parallel(true)
	_tween.tween_property(_sprite, "scale", Vector2(0.46,0.46), wrapup_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_tween.tween_property(_sprite, "modulate", Color.WHITE, wrapup_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await _tween.finished
