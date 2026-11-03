class_name ShopScene
extends MenuScene
## Permanent upgrades bought with stardust.

var dust_label := Txt.make("", 26, Palette.VIOLET, 1)
var rows: Array = []


func _init() -> void:
	super._init()
	hole = 170.0
	var title := Txt.make("Upgrades", 36, Palette.CREAM)
	title.position = Vector2(0, -240)
	ui.add_child(title)
	var sub := Txt.make("Spend stardust. These stay with you for every night to come.", 17, Palette.MUTED)
	sub.position = Vector2(0, -206)
	sub.fit_width = 860.0
	ui.add_child(sub)
	ui.add_child(dust_label)
	var list := []
	for i in Data.SHOP.size():
		var item: Dictionary = Data.SHOP[i]
		var b := GButton.make("", 680, 54, 20, func(): _buy(item))
		b.position = Vector2(0, -162 + i * 58)
		ui.add_child(b)
		rows.append([item, b])
		list.append(b)
	var back := GButton.make("Back", 220, 60, 22, on_back)
	back.position = Vector2(0, 216)
	ui.add_child(back)
	list.append(back)
	set_buttons(list)
	_refresh()


func layout_ui() -> void:
	dust_label.position = Vector2(W() / 2.0 - safe_margins().right, -240)
	# Narrow tablets get slimmer rows.
	var row_w := minf(680.0, W() - 32.0)
	for r in rows:
		r[1].w = row_w
		r[1].queue_redraw()
	_refresh()


func _refresh() -> void:
	dust_label.text = "%d ✦" % int(Save.d.stardust)
	for r in rows:
		var item: Dictionary = r[0]
		var b: GButton = r[1]
		for c in b.get_children():
			c.queue_free()
		var l := Save.shop_level(item.id)
		var edge := -b.w / 2.0
		var icon := BaseScene.icon_node(item.icon, 32)
		icon.position = Vector2(edge + 32, 0)
		b.add_child(icon)
		var n := Txt.make(item.name, 20, Palette.CREAM, -1)
		n.position = Vector2(edge + 62, -11)
		b.add_child(n)
		var d := Txt.make(item.blurb, 15, Palette.MUTED, -1)
		d.position = Vector2(edge + 62, 12)
		b.add_child(d)
		for i in int(item.max):
			var pip := Sprite2D.new()
			pip.texture = Art.tex("dot")
			pip.scale = Vector2.ONE * 12.0 / 64.0
			pip.modulate = Palette.GOLD if i < l else Color(1, 1, 1, 0.18)
			pip.position = Vector2(b.w / 2.0 - 190 + i * 16, 0)
			b.add_child(pip)
		var maxed: bool = l >= int(item.max)
		var cost: int = int(item.cost) * (l + 1)
		var can_afford: bool = not maxed and int(Save.d.stardust) >= cost
		var price := Txt.make("MAX" if maxed else "%d ✦" % cost, 20, Palette.GOLD if maxed else (Palette.VIOLET if can_afford else Palette.MUTED), 1)
		price.position = Vector2(b.w / 2.0 - 18, 0)
		b.add_child(price)


func _buy(item: Dictionary) -> void:
	var l := Save.shop_level(item.id)
	var cost: int = int(item.cost) * (l + 1)
	if l >= int(item.max) or int(Save.d.stardust) < cost: return
	Save.d.stardust = int(Save.d.stardust) - cost
	Save.d.shop[item.id] = l + 1
	Save.write()
	Sound.play("buy", 1.0, 0.0)
	_refresh()


func on_back() -> void:
	Main.I.go_to(TitleScene.new())
