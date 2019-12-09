extends BuildingBlock

var is_max := false
var scaling_up := false
var ready_to_scale := false
var mesh_node
var mesh_maxi_scale
var collision_shape_node
var collision_shape_node_shape
var collision_shape_initial_extents
var collision_shape_maxi_extents
var expand_speed := 2.0
var lerp_weight := 0.0
var start_time := 0.0
var mesh_initial_scale : Vector3
var collision_shape_initial_scale : Vector3
var mesh_mini_scale : Vector3
var collision_shape_mini_scale : Vector3


export(float) var mini_scale_factor
export(NodePath) var mesh_node_path
export(NodePath) var collision_shape_node_path

export(PackedScene) var maxi_scene

func _ready():
	connect("body_entered", self, "_on_Mini_body_entered")
	
	# get nodes and apply the scale factor
	mesh_node = get_node(mesh_node_path)
	
	if mesh_node:
		mesh_initial_scale = mesh_node.scale
		mesh_maxi_scale = mesh_initial_scale / mini_scale_factor
	else:
		print("No Mesh node assigned")

	collision_shape_node = get_node(collision_shape_node_path)
	if collision_shape_node:
		collision_shape_node_shape = collision_shape_node.get_shape()
		collision_shape_initial_extents = collision_shape_node_shape.get_extents()
		collision_shape_maxi_extents = collision_shape_initial_extents / mini_scale_factor
	else:
		print("No CollisionShape node assigned")


func _process(delta):
	# check if it's moving or not so we only scale up if it's not moving
	if ready_to_scale:
		if linear_velocity.length() < 0.001 and angular_velocity.length() < 0.001:
			scaling_up = true
	
	if scaling_up:
		ready_to_scale = false
		# scale up over time as user removes the mini frmo the tablet
		lerp_weight = start_time / expand_speed

		var temp_scale_mesh = lerp(mesh_initial_scale, mesh_maxi_scale, lerp_weight)
		var temp_extents_collision_shape = lerp(collision_shape_initial_extents, collision_shape_maxi_extents, lerp_weight)


		if mesh_node:
			mesh_node.scale = temp_scale_mesh

		if collision_shape_node:
			collision_shape_node_shape.set_extents(temp_extents_collision_shape)

		start_time += delta

		if lerp_weight > 1:
			lerp_weight = 0
			scaling_up = false
			start_time = 0.0
			is_max = true
			switch_to_maxi()


func _on_Mini_body_entered(body):
	if body.name != "Table": return
	
	maximize()

func grab_init(node):
	.grab_init(node)
	# turn on gravity
	gravity_scale = 1.0


# maximizes a mini
func maximize():
	if is_max or scaling_up or is_grabbed: return
	
	# scale up
	ready_to_scale = true


func switch_to_maxi():
	# instance maxi node
	var main_node = get_node("/root/Main")
	var new_maxi = maxi_scene.instance()
	main_node.add_child(new_maxi)
	
	# set to correct position and rotation
	new_maxi.transform.origin = transform.origin
	new_maxi.rotation = rotation
	
	# destroy this node
	queue_free()