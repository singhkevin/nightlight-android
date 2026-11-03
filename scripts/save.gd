extends Node
## Progress kept on the phone. Test runs never write it.

const PATH := "user://save.json"

var d := {
	"stardust": 0, "totalKills": 0, "runs": 0, "dawns": 0, "bestTime": 0.0, "bestScore": 0,
	"shop": {}, "unlocked": ["candle"], "selected": "candle", "muted": false, "dailyDay": -1, "dailyBest": 0,
}


func _init() -> void:
	if not FileAccess.file_exists(PATH): return
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(PATH))
	if parsed is Dictionary:
		for k in parsed:
			d[k] = parsed[k]
		# JSON stores every number as a decimal; the game counts in whole numbers.
		for k in ["stardust", "totalKills", "runs", "dawns", "bestScore", "dailyDay", "dailyBest"]:
			d[k] = int(d[k])


func write() -> void:
	if Main.test_mode: return
	var tmp := PATH + ".tmp"
	var f := FileAccess.open(tmp, FileAccess.WRITE)
	if f == null: return
	f.store_string(JSON.stringify(d))
	f.close()
	DirAccess.rename_absolute(tmp, PATH)


func shop_level(id: String) -> int:
	return int(d.shop.get(id, 0))
