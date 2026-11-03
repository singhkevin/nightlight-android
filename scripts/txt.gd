class_name Txt
extends Node2D
## A piece of on-screen text, centred on its position unless told otherwise.

var text := "":
	set(v):
		if v != text:
			text = v
			queue_redraw()
var font_size := 20
var color := Color.WHITE:
	set(v):
		color = v
		queue_redraw()
var align := 0                # -1 left, 0 centre, 1 right
var wrap_width := 0.0         # above zero: wrap into lines, growing downwards from this position
var fit_width := 0.0          # above zero: shrink to fit on one line


static func make(s: String, size: int, c := Color.WHITE, a := 0) -> Txt:
	var t := Txt.new()
	t.text = s
	t.font_size = size
	t.color = c
	t.align = a
	return t


func _draw() -> void:
	if text == "": return
	var f := Art.font()
	var fs := font_size
	if wrap_width > 0.0:
		draw_multiline_string(f, Vector2(-wrap_width / 2.0, f.get_ascent(fs)), text, HORIZONTAL_ALIGNMENT_CENTER, wrap_width, fs, -1, color)
		return
	var w := f.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	if fit_width > 0.0 and w > fit_width:
		fs = maxi(10, int(fs * fit_width / w))
		w = f.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	var x := 0.0
	if align == 0: x = -w / 2.0
	elif align > 0: x = -w
	draw_string(f, Vector2(x, (f.get_ascent(fs) - f.get_descent(fs)) / 2.0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, color)
