@tool
class_name TextureRegistry
extends RefCounted

static var _textures: Dictionary = {}
static var _loaded := false

static func load_from_json(json_path: String, texture_dir: String) -> bool:
	var file := FileAccess.open(json_path, FileAccess.READ)
	if file == null:
		push_error("Can't open %s (error %d)" % [json_path, FileAccess.get_open_error()])
		return false
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		push_error("JSON error line %d: %s" % [json.get_error_line(), json.get_error_message()])
		return false
	if typeof(json.data) != TYPE_DICTIONARY:
		push_error("Texture JSON must be an object of name -> path")
		return false
	var base := texture_dir
	var result := {}
	for key in json.data:
		var path: String = json.data[key]
		if not path.begins_with("res://"):
			path = base.path_join(path)
		result[key] = path

	_textures = result
	_loaded = true
	return true


	

static func _is_loaded() -> bool:
	return _loaded

static func get_names():
	if _loaded:
		return PackedStringArray(_textures.keys())
	else:
		return null

static func get_texture(tex_name: String) -> String:
	if _loaded:
		return _textures.get(tex_name)
	else:
		return ""
		
