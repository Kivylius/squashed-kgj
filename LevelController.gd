extends Node3D

@export var leftpan: Area3D = null
@export var right_pan: Area3D = null
@export var crash_zone: Area3D = null
@export var finish_zone: Area3D = null
@export var out_of_bounds: Area3D = null
@export var label: Label = null
@export var menu: Node2D = null

var camera: Camera3D

var weight_count = 0;
var weights = [];
var boats_count = 0;
var boats = [];

#game vars
var crash = false;
var finished = false;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera = get_viewport().get_camera_3d()
	camera.fov = 179.0
	weights = get_tree().get_nodes_in_group("weights")
	boats = get_tree().get_nodes_in_group("boats")
	weight_count = weights.size();
	boats_count = boats.size();
	print("weights:", weight_count, ", boats:", boats_count)
	create_tween().tween_property(camera, "fov", 35, 0.5)
	
	#connect all the dots
	if leftpan and right_pan and crash_zone and finish_zone and menu and out_of_bounds:
	
		leftpan.body_entered.connect(pan_enter);
		leftpan.body_exited.connect(pan_exit);
		right_pan.body_entered.connect(pan_enter);
		right_pan.body_exited.connect(pan_exit);
		
		crash_zone.body_exited.connect(crash_zone_exited);
		 
		finish_zone.body_entered.connect(finish_enter);
		
		menu.retry_action.connect(retry_pressed);
		menu.next_action.connect(complete_pressed);
		
		out_of_bounds.body_entered.connect(out_of_bounds_enter);
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	# stop procesisng once game is finiuhed
	if finished == true:
		return
		
	#print("hi", finished, menu.failed, 	DragDropController.draggables, DragDropController.draggables_parents);
	
	if label:
		label.text = "boats left: " + str(boats_count) + ", \nweights: " + str(weight_count) + " \ncrashed: " + str(crash) + ", \n"
		
		#failed states
		if crash:
			label.text = "crash"
			finished = true;
			menu.failed = true;
			
		if boats_count == 0 and weight_count > 0:
			label.text = "did not place cube in time"
			finished = true
			menu.failed = true;
			
		#level completed
		if weight_count == 0 and boats_count == 0 and not crash:
			finished = true;
			menu.completed = true;
			label.text = "complated"
		
	pass

func pan_enter(body: Node3D) -> void:
	if body.is_in_group("weights"):
		print("pan enter",body)
		weight_count -= 1
	pass

func pan_exit(body: Node3D) -> void:
	if body.is_in_group("weights"):
		print("pan exit", body)
		weight_count += 1
	pass
	
func crash_zone_exited(body: Node3D) -> void:
	print("exit:", body)
	if body.is_in_group("beam"):
		crash = true
	pass
	
func finish_enter(body: Node3D) -> void:
	print("enter:", body)
	if body.is_in_group("boats"):
		boats_count -= 1
		
func out_of_bounds_enter(body: Node3D) -> void:
	print("ofb enter:", body)
	if body.is_in_group("weights"):
		crash = true
		
func retry_pressed() -> void:
	print("pressing retry")
	DragDropController.draggables = []
	DragDropController.draggables_parents = []
	#get_tree().change_scene_to_file("res://main.tscn")
	get_tree().reload_current_scene()
	
func complete_pressed() -> void:
	print("pressing compalte")
	DragDropController.draggables = []
	DragDropController.draggables_parents = []
	#dont jugne me running out of time lol
	DragDropController.current_level += 1
	await create_tween().tween_property(camera, "fov", 1.1, 0.5).finished
	get_tree().change_scene_to_file("res://" + DragDropController.levels[DragDropController.current_level] + ".tscn")
	#get_tree().change_scene_to_file("res://main.tscn")
