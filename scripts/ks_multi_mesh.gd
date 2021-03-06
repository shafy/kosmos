extends MultiMeshInstance


class_name KSMultiMesh


var area_index : Dictionary


func add_area(area : Area, color: Vector3) -> void:
	# add block to MultiMeshInstance
	# save old transforms
	# increment visibility 
	var new_count = multimesh.visible_instance_count + 1
	multimesh.set_visible_instance_count(new_count)
	
	# update position of new instance
	var new_color = Color(color.x, color.y, color.z, 1.0)
	multimesh.set_instance_transform(new_count - 1, area.get_global_transform())
	multimesh.set_instance_custom_data(new_count - 1, new_color)
	
	# add to index
	area_index[area] = {"global_transform": area.get_global_transform(), "color": new_color}


func remove_area(area : Area) -> void:
	# remove block from MultiMeshInstance
	# try erasing
	if !area_index.erase(area):
		return
	
	# if erased successfully, set instances again
	
	var new_count = multimesh.visible_instance_count - 1
	multimesh.set_visible_instance_count(new_count)
	
	set_instances()


func set_instances() -> void:
	var area_index_values = area_index.values()
	for i in range(area_index_values.size()):
		multimesh.set_instance_transform(i, area_index_values[i]["global_transform"])
		multimesh.set_instance_custom_data(i, area_index_values[i]["color"])
