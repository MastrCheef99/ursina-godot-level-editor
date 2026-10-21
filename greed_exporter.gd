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
