class_name GButton
extends Node2D
## Anything tappable: menu items, upgrade cards, shop rows.

var w := 260.0
var h := 62.0
var radius := 14
var plain := false            # no background, just a tap area (the flame arrows)
var action: Callable
var disabled := false:
	set(v):
		disabled = v
		modulate.a = 0.5 if v else 1.0
		queue_redraw()
var pressed := false:
	set(v):
		if v != pressed:
			pressed = v
			queue_redraw()
			var tw := create_tween()
			tw.tween_property(self, "scale", Vector2.ONE * (0.97 if v else 1.0), 0.07)
var title: Txt
var _sb := StyleBoxFlat.new()


static func make(s: String, width: float, height: float, size: int, act: Callable) -> GButton:
	var b := GButton.new()
	b.w = width
	b.h = height
	b.action = act
	if s != "":
		b.title = Txt.make(s, size, Palette.CREAM)
		b.title.fit_width = width - 20.0
		b.add_child(b.title)
	return b


func _draw() -> void:
	if plain: return
	_sb.bg_color = Palette.PANEL_HI if pressed else Palette.PANEL
	_sb.border_color = Palette.GOLD if pressed else Palette.LINE
	_sb.set_border_width_all(2)
	_sb.set_corner_radius_all(radius)
	draw_style_box(_sb, Rect2(-w / 2.0, -h / 2.0, w, h))


## True if the point is on the button. `slop` lets a sloppy finger count, and small buttons get at least a thumb-sized target.
func hit(global_point: Vector2, slop := 0.0) -> bool:
	var q := to_local(global_point)
	var hw := maxf(w, 56.0) / 2.0 + slop
	var hh := maxf(h, 56.0) / 2.0 + slop
	return absf(q.x) <= hw and absf(q.y) <= hh
