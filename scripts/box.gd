class_name Box
extends Node2D
## A plain filled rectangle, drawn from its left-centre, for bars and dim layers.

var size := Vector2(10, 10):
	set(v):
		if v != size:
			size = v
			queue_redraw()
var color := Color.WHITE:
	set(v):
		if v != color:
			color = v
			queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(0, -size.y / 2.0, size.x, size.y), color)
