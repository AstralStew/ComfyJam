class_name NewQueenPlus extends Node

@onready var background : Panel 

@export var transition_time : float = 1.0
@export var transition_start_pos : Vector2 = Vector2.ZERO
@export var transition_mid_pos : Vector2 = Vector2.ZERO
@export var transition_end_pos : Vector2 = Vector2.ZERO

var wipe_tween : Tween = null

func _enter_tree() -> void:
	HiveManager.on_hive_start().connect(start_wipe)
	HiveManager.on_hive_finish().connect(end_wipe)
	
	background = $Background
	
	#background.position = transition_mid_pos
	

func start_wipe() -> void:
	if wipe_tween: wipe_tween.kill()
	
	
	await get_tree().process_frame
	wipe_tween = create_tween().set_parallel()
	wipe_tween.tween_property(background,"position",transition_end_pos,transition_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	await get_tree().create_timer(transition_time,true).timeout

	background.visible = false


func end_wipe() -> void:
	if wipe_tween: wipe_tween.kill()
	
	await get_tree().process_frame
	background.position = transition_start_pos
	background.visible = true
	
	wipe_tween = create_tween().set_parallel()
	wipe_tween.tween_property(background,"position",transition_mid_pos,transition_time)
	await get_tree().create_timer(transition_time,true).timeout
	
	await get_tree().create_timer(1).timeout
	
	HiveManager.wipe_hive()
	
	await HiveManager.on_wipe_scene()
	
	$Button.visible = true


func _on_button_pressed() -> void:
	
	
	await get_tree().process_frame
	get_tree().call_deferred("reload_current_scene")
	#.reload_current_scene()
