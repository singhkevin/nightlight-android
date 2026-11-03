class_name BaseScene
extends Node2D
## Shared by every screen: a screen-sized UI layer whose (0,0) is the centre of the screen, and tap handling.

var ui_layer := CanvasLayer.new()
var ui := Node2D.new()
var buttons: Array = []
var input_lock_until := 0.0
var _pressed: GButton
var _press_id := -1


func _init() -> void:
	ui_layer.layer = 10
	add_child(ui_layer)
	ui_layer.add_child(ui)


func W() -> float: return get_viewport_rect().size.x
func H() -> float: return get_viewport_rect().size.y


func _ready() -> void:
	get_viewport().size_changed.connect(_resized)
	_resized()


func _resized() -> void:
	ui.position = get_viewport_rect().size / 2.0
	layout_ui()


func layout_ui() -> void:
	pass


## Space to keep clear of the phone's camera cut-out and rounded corners, in screen units:
## left, right, top, bottom. Never less than a thumb's width at the sides, whatever the phone reports.
func safe_margins() -> Dictionary:
	var m := {"left": 40.0, "right": 40.0, "top": 10.0, "bottom": 10.0}
	var win := DisplayServer.window_get_size()
	if win.x <= 0 or win.y <= 0: return m
	var sa := DisplayServer.get_display_safe_area()
	var kx := W() / float(win.x)
	var ky := H() / float(win.y)
	m.left = maxf(m.left, sa.position.x * kx + 10.0)
	m.right = maxf(m.right, (win.x - sa.end.x) * kx + 10.0)
	m.top = maxf(m.top, sa.position.y * ky + 6.0)
	m.bottom = maxf(m.bottom, (win.y - sa.end.y) * ky + 6.0)
	return m


func set_buttons(list: Array) -> void:
	buttons = list
	_pressed = null
	_press_id = -1
	_press_time = 0.0


var _press_time := 0.0
const TAP_SLOP := 28.0        # a finger may roll this far off a button and still count


func now() -> float:
	return Time.get_ticks_msec() / 1000.0


func _input(event: InputEvent) -> void:
	if Main.test_mode and event.device != Main.TEST_DEVICE: return
	if Main.I.switching: return
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		on_touch(event)


func on_touch(event: InputEvent) -> void:
	button_touch(event)


## A button fires when a finger lands on it and lifts on it, so a thumb already on the glass can't pick a card by accident.
func button_touch(event: InputEvent) -> void:
	if not (event is InputEventScreenTouch): return
	if event.pressed:
		# A finger that never reported lifting (a palm, a gesture the phone took over) must not block every later tap.
		if _pressed != null and (event.index == _press_id or now() - _press_time > 1.5):
			_release_pressed()
		if _pressed != null: return
		for b: GButton in buttons:
			if is_instance_valid(b) and not b.disabled and b.hit(event.position, TAP_SLOP):
				_pressed = b
				_press_id = event.index
				_press_time = now()
				b.pressed = true
				return
	elif event.index == _press_id:
		var b := _release_pressed()
		if event.is_canceled(): return
		if b != null and b.hit(event.position, TAP_SLOP) and now() >= input_lock_until and buttons.has(b) and not b.disabled:
			Sound.play("button")
			b.action.call()


func _release_pressed() -> GButton:
	var b := _pressed
	_pressed = null
	_press_id = -1
	if is_instance_valid(b):
		b.pressed = false
		return b
	return null


func on_back() -> void:
	pass


## A flame with a little face, used on the menus.
static func make_flame_node(def: Dictionary, height: float) -> Node2D:
	var root := Node2D.new()
	var glow := Sprite2D.new()
	glow.texture = Art.tex("soft_dot")
	glow.material = Art.additive()
	glow.scale = Vector2.ONE * height * 3.4 / 128.0
	glow.modulate = Color(def.outer, 0.55)
	root.add_child(glow)
	var body := Sprite2D.new()
	body.texture = Art.tex("flame_" + def.id)
	var bs := Vector2(height * 0.8 / 128.0, height / 160.0)
	body.scale = bs
	root.add_child(body)
	var face := Sprite2D.new()
	face.texture = Art.tex("flame_face")
	var fs := Vector2(height * 0.42 / 64.0, height * 0.21 / 32.0)
	face.scale = fs
	face.position = Vector2(0, height * 0.13)
	root.add_child(face)
	var tw := body.create_tween().set_loops()
	tw.tween_property(body, "scale", bs * Vector2(0.95, 1.05), 0.22)
	tw.tween_property(body, "scale", bs * Vector2(1.03, 0.97), 0.26)
	var tf := face.create_tween().set_loops()
	tf.tween_interval(2.6)
	tf.tween_property(face, "scale:y", fs.y * 0.1, 0.05)
	tf.tween_property(face, "scale:y", fs.y, 0.06)
	return root


static func icon_node(name: String, size: float) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = Art.icon(name)
	s.scale = Vector2.ONE * size / float(s.texture.get_width())
	return s
