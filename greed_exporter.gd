@tool
extends EditorPlugin

var dock : EditorDock

func _enable_plugin() -> void:
	# Add autoloads here.
	pass


func _disable_plugin() -> void:
	# Remove autoloads here.
	pass


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	var dock_scene = preload("res://addons/greed_exporter/greed_exporter_dock.tscn").instantiate()
	dock = EditorDock.new()
	dock_scene.plugin_node = self
	dock.add_child(dock_scene)
	dock.title = "Greed Exporter"
	dock.default_slot = EditorDock.DOCK_SLOT_RIGHT_BL
	dock.available_layouts = EditorDock.DOCK_LAYOUT_VERTICAL | EditorDock.DOCK_LAYOUT_FLOATING
	add_dock(dock)


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	for d in dock.get_children():
		if d.name == "Greed Exporter":
			d.save_config()
	remove_dock(dock)
	dock.queue_free()

const BrickScript = preload("res://addons/greed_exporter/UrsinaBox3D.gd")


func import_bricks(py_path: String) -> void:
	var file := FileAccess.open(py_path, FileAccess.READ)
	if file == null:
		push_error("Could not open: " + py_path)
		return

	var root := get_editor_interface().get_edited_scene_root()
	if root == null:
		push_error("Open a scene before importing bricks.")
		return
	var i = 1
	while not file.eof_reached():
		var line := file.get_line().strip_edges()
		if not line.begins_with("Brick("):
			continue

		var data := _parse_brick_line(line)
		if data.is_empty():
			continue

		var brick = BrickScript.new(data)
		brick.name = "UrsinaBox3D" + str(i)
		root.add_child(brick)
		brick.owner = root
		i += 1


func _parse_brick_line(line: String) -> Dictionary:
	var data := {}

	var position := _tuple_arg(line, "position")
	if position.size() == 3:
		data["position"] = Vector3(position[0], position[1], position[2])

	var scale_text := _arg_value(line, "scale")
	if scale_text != "":
		var scale_tuple := _parse_tuple(scale_text)
		if scale_tuple.size() == 3:
			data["scale"] = Vector3(scale_tuple[0], scale_tuple[1], scale_tuple[2])
		elif scale_text.is_valid_float():
			var s := float(scale_text)
			data["scale"] = Vector3.ONE * s

	var rx := _float_arg(line, "rotation_x", 0.0)
	var ry := _float_arg(line, "rotation_y", 0.0)
	var rz := _float_arg(line, "rotation_z", 0.0)
	data["rotation"] = Vector3(deg_to_rad(rx), deg_to_rad(ry), deg_to_rad(rz))

	var texture_scale := _tuple_arg(line, "texture_scale")
	if texture_scale.size() >= 2:
		data["texture_scale"] = Vector2(texture_scale[0], texture_scale[1])

	var color_text := _arg_value(line, "color")
	if color_text.begins_with("("):
		var c := _parse_tuple(color_text)
		if c.size() >= 3:
			data["color"] = Color(c[0], c[1], c[2], c[3] if c.size() > 3 else 1.0)

	var texture_match := RegEx.new()
	texture_match.compile('texture\\s*=\\s*textures\\["([^"]+)"\\]')
	var found := texture_match.search(line)
	if found:
		data["texture"] = found.get_string(1)
	

	var collider := _arg_value(line, "collider")
	if collider != "":
		data["collider"] = collider.strip_edges().trim_prefix('"').trim_suffix('"')

	return data


func _arg_value(line: String, name: String) -> String:
	var regex := RegEx.new()
	regex.compile(name + '\\s*=\\s*(\\([^)]*\\)|[^,)]*)')
	var match_result := regex.search(line)
	return match_result.get_string(1).strip_edges() if match_result else ""


func _tuple_arg(line: String, name: String) -> Array:
	return _parse_tuple(_arg_value(line, name))


func _parse_tuple(text: String) -> Array:
	text = text.strip_edges().trim_prefix("(").trim_suffix(")")
	var result: Array = []
	for part in text.split(","):
		var value := part.strip_edges()
		if value.is_valid_float():
			result.append(float(value))
	return result


func _float_arg(line: String, name: String, fallback: float) -> float:
	var value := _arg_value(line, name)
	return float(value) if value.is_valid_float() else fallback
