@tool
class_name UrsinaBox3D extends CSGBox3D

@export var texture : String = "" :
	set(value):
		texture = value
		apply_texture(value)
@export var color : Color = Color.WHITE :
	set(value):
		color = value
		apply_color(value)
@export var texture_scale : Vector2 = Vector2.ONE :
	set(value):
		texture_scale = value
		apply_texture_scale(value)
		
@export var collider : String = "box"


func refresh():
	apply_texture(texture)

func _enter_tree() -> void:
	add_to_group("Ursina Boxes")
	if not material:
		material = StandardMaterial3D.new()
	
func _ready() -> void:
	if TextureRegistry._is_loaded():
		apply_texture(texture)
	if not material:
		material = StandardMaterial3D.new()

func apply_texture(tex : String):
	if not TextureRegistry._is_loaded():
		return
	if not material:
		material = StandardMaterial3D.new()
	if TextureRegistry.get_names().find(tex) != -1:
		material.albedo_texture = load(TextureRegistry.get_texture(tex)) as Texture2D
	else:
		material.albedo_texture = null
		
func apply_color(col : Color):
	if not material:
		material = StandardMaterial3D.new()
	material.albedo_color = col
	
func apply_texture_scale(scale : Vector2):
	if not material:
		material = StandardMaterial3D.new()
	if TextureRegistry._is_loaded() and TextureRegistry.get_names().find(texture) == -1:
		texture_scale = Vector2.ONE
		return
	material.uv1_scale = Vector3(scale.x, scale.y, 1)
