class_name Art
## Loads pictures and fonts once. The pictures are exact copies of what the Mac game draws by code.

static var _cache := {}
static var _font: Font


static func tex(name: String) -> Texture2D:
	if not _cache.has(name):
		_cache[name] = load("res://assets/art/%s.png" % name)
	return _cache[name]


static func icon(name: String) -> Texture2D:
	var key := "icon/" + name
	if not _cache.has(key):
		_cache[key] = load("res://assets/icons/%s.png" % name)
	return _cache[key]


static func font() -> Font:
	if _font == null:
		var f: FontFile = load("res://assets/fonts/Nunito-ExtraBold.ttf")
		f.fallbacks = [load("res://assets/fonts/Symbols.ttf")]
		_font = f
	return _font


static var _add: CanvasItemMaterial


## Shared "glow" blending: colours add up instead of covering what's below.
static func additive() -> CanvasItemMaterial:
	if _add == null:
		_add = CanvasItemMaterial.new()
		_add.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	return _add
