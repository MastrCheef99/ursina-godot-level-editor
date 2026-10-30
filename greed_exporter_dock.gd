@tool
extends Control
@onready var output_file_dialog = $OutputFileDialog
@onready var import_file_dialog = $ImportFileDialog
var output_path : String
var plugin_node
@onready var output_path_input : LineEdit = $VBoxContainer/HBoxContainer/Output_Path

@onready var input_path_input : LineEdit = $VBoxContainer/HBoxContainer4/Import_Path

@onready var texture_file_dialog : FileDialog = $TextureFileDialog
@onready var texture_path_input : LineEdit = $VBoxContainer/HBoxContainer2/Texture_Path
@onready var texture_dict_file_dialog : FileDialog = $TextureDictFileDialog
@onready var texture_dict_path_input : LineEdit = $VBoxContainer/HBoxContainer3/Texture_Dict_Path

var config : ConfigFile = ConfigFile.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var err = config.load("user://greed_export_defaults.cfg")
	if err != OK:
		config = ConfigFile.new()
		return
	output_path = config.get_value("defaults", "output_path", "")
	output_path_input.text = output_path
	
	texture_path_input.text = config.get_value("defaults", "texture_path", "")
	texture_dict_path_input.text = config.get_value("defaults", "texture_dict_path", "")
	var images_loaded = TextureRegistry.load_from_json(texture_dict_path_input.text, texture_path_input.text)
	if images_loaded:
		get_tree().call_group("Ursina Block", "refresh")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func save_config():
	config.save("user://greed_export_defaults.cfg")

func _on_output_file_dialog_pressed() -> void:
	output_file_dialog.popup_centered_clamped()



func _on_open_output_path_pressed() -> void:
	output_path = output_path_input.text
	config.set_value("defaults", "output_path", output_path)
	print("Output folder set")


func _on_output_file_dialog_dir_selected(dir: String) -> void:
	output_path_input.text = dir


func _on_texture_file_dialog_pressed() -> void:
	texture_file_dialog.popup_centered_clamped()

func _on_texture_file_dialog_dir_selected(dir: String) -> void:
	texture_path_input.text = dir

func _on_import_textures_path_pressed() -> void:
	print("Importing Textures...")
	var images_loaded = TextureRegistry.load_from_json(texture_dict_path_input.text, texture_path_input.text)
	if images_loaded:
		get_tree().call_group("Ursina Block", "refresh")
		config.set_value("defaults", "texture_path", texture_path_input.text)
		config.set_value("defaults", "texture_dict_path", texture_dict_path_input.text)
	else:
		print("Failed to load textures")


func _on_texture_dict_file_dialog_file_selected(path: String) -> void:
	texture_dict_path_input.text = path


func _on_texture_dict_file_dialog_pressed() -> void:
	texture_dict_file_dialog.popup_centered_clamped()


func _on_button_pressed() -> void:
	print("Exporting level...")
	if not TextureRegistry._is_loaded():
		push_error("Please add your textures")
		return
		
	if not DirAccess.dir_exists_absolute(output_path):
		push_error("Output folder " + output_path+ " doesn't exist or something. I'm lazy so I'm not fixing that: ", FileAccess.get_open_error())
		return
	var filename = output_path+"/"+Time.get_datetime_string_from_system().replace(":", "-").replace("T", "_")+".py"
	var file := FileAccess.open(filename, FileAccess.WRITE)
		
	if file == null:
		push_error("Can't open %s (error %d)" % [filename, FileAccess.get_open_error()])
		return
	file.store_string("[")
	var level = EditorInterface.get_edited_scene_root()
	var level_nodes = level.get_children()
	for brick in level_nodes:
		if not brick.is_in_group("Ursina Boxes"):
			continue
		if TextureRegistry.get_names().find(brick.texture) == -1:
			push_warning("Texture on " + brick.name + " called " + brick.texture + " not found, skipping")
			continue
		var brick_texture = brick.texture
		var pos = brick.global_position
		var rot = brick.global_rotation_degrees
		var truescale = brick.scale*brick.size
		file.store_string(
			"Brick(self, position = ("+str(round_place(pos.x,3))+","+str(round_place(pos.y,3))+","+str(round_place(pos.z,3))+
			"),scale = ("+str(round_place(truescale.x,3))+","+str(round_place(truescale.y,3))+"," + str(round_place(truescale.z,3)) + 
			"), rotation = ("+str(round_place(rot.x,3))+","+str(round_place(rot.y,3))+"," + str(round_place(rot.z,3))+")"+
			", texture=textures[\"" + brick.texture + "\"]" +
			", texture_scale=(" + str(round_place(brick.texture_scale.x,3)) + "," + str(round_place(brick.texture_scale.y,3)) + ")" +
			", color=color.hex(\"#" + brick.material.albedo_color.to_html() + "\")" +
			", collider=\"" + brick.collider +"\"" +
			"),\n"
		)
	file.store_string("]")
	file.close()
	print("Level exported!")

func round_place(num,places):
	return (round(num*pow(10,places))/pow(10,places))


func _on_import_path_file_dialog_pressed() -> void:
	import_file_dialog.popup_centered_clamped()



func _on_import_file_dialog_file_selected(path: String) -> void:
	input_path_input.text = path


func _on_button_2_pressed() -> void:
	import_level()
	
func import_level() -> void:
	plugin_node.import_bricks(input_path_input.text)
