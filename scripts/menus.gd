class_name MenuScene
extends BaseScene
## Shared backdrop for the menus: a dark forest with blinking eyes watching from the edge of the light.

var backdrop := Node2D.new()
var focus := Vector2.ZERO          # where the pool of light sits, relative to the screen centre
var hole := 300.0
var _dark: ColorRect
var _mat: ShaderMaterial
var _eyes: Array[Sprite2D] = []


func _init() -> void:
	super._init()
	add_child(backdrop)
	var ground := Art.tex("ground")
	for ix in range(-2, 3):
		for iy in range(-1, 2):
			var tile := Sprite2D.new()
			tile.texture = ground
			tile.scale = Vector2.ONE * 1025.0 / 1024.0
			tile.position = Vector2(ix, iy) * 1024.0
			backdrop.add_child(tile)
	_dark = ColorRect.new()
	_dark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_mat = ShaderMaterial.new()
	_mat.shader = load("res://shaders/darkness.gdshader")
	_mat.set_shader_parameter("strength", 0.97)
	_dark.material = _mat
	_dark.size = Vector2(5000, 5000)
	_dark.position = -_dark.size / 2.0
	_mat.set_shader_parameter("sheet", 5000.0)
	backdrop.add_child(_dark)
	for i in 14:
		var e := Sprite2D.new()
		e.texture = Art.tex("eyes")
		e.modulate = Color(1, 0.96, 0.8, 0)
		backdrop.add_child(e)
		_eyes.append(e)


func _ready() -> void:
	super._ready()
	_mat.set_shader_parameter("radius", hole)
	Sound.start_music(0.4)
	for e in _eyes:
		_blink(e, randf_range(0.0, 6.0))


func _resized() -> void:
	super._resized()
	backdrop.position = get_viewport_rect().size / 2.0 + focus


func _blink(e: Sprite2D, delay: float) -> void:
	var tw := e.create_tween()
	if delay > 0.0: tw.tween_interval(delay)
	tw.tween_callback(func():
		var a := randf() * TAU
		var size := get_viewport_rect().size
		e.position = Vector2(cos(a) * randf_range(size.x * 0.42, size.x * 0.52), sin(a) * randf_range(size.y * 0.40, size.y * 0.50)) - focus
		var s := randf_range(20.0, 40.0) / 96.0
		e.scale = Vector2(s, s))
	tw.tween_property(e, "modulate:a", 0.9, 0.4)
	tw.tween_interval(randf_range(0.8, 2.4))
	tw.tween_property(e, "scale:y", 0.02, 0.05)
	tw.tween_method(func(v: float): e.scale.y = e.scale.x * v, 0.1, 1.0, 0.06)
	tw.tween_interval(randf_range(0.6, 1.8))
	tw.tween_property(e, "modulate:a", 0.0, 0.4)
	tw.tween_interval(randf_range(0.2, 2.6))
	tw.finished.connect(func(): _blink(e, 0.0))
