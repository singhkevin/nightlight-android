class_name Main
extends Node
## Starts the game, swaps screens, and handles the phone's Back button and app switching.
## Test switches (after `--`): --balance N flame, --selftest dir, --perf dir. Players never see them.

const TEST_DEVICE := -9

static var I: Main
static var test_mode := false

var current: Node
var switching := false
var _fade: ColorRect


func _ready() -> void:
	I = self
	var args := OS.get_cmdline_user_args()
	# Test builds on a phone take their switches from a small file, as Android drops launch arguments.
	const TEST_FILE := "user://test_args.txt"
	if OS.is_debug_build() and OS.has_feature("android") and FileAccess.file_exists(TEST_FILE):
		args = PackedStringArray(FileAccess.get_file_as_string(TEST_FILE).strip_edges().split(" "))
	# `--maxshop` runs the bot as if every stat upgrade in the shop were bought (dice and fourth card excluded).
	if args.has("--maxshop"):
		for id in ["flame", "power", "feet", "wisdom"]: Save.d.shop[id] = 5
	var flag := args.find("--balance")
	if flag >= 0:
		test_mode = true
		Sound.enabled = false
		_run_balance(int(args[flag + 1]), args[flag + 2] if args.size() > flag + 2 and not args[flag + 2].begins_with("--") else "candle")
		get_tree().quit()
		return
	flag = args.find("--curve")
	if flag >= 0:
		test_mode = true
		Sound.enabled = false
		_run_curve(int(args[flag + 1]), args[flag + 2] if args.size() > flag + 2 and not args[flag + 2].begins_with("--") else "candle")
		get_tree().quit()
		return

	var layer := CanvasLayer.new()
	layer.layer = 100
	add_child(layer)
	_fade = ColorRect.new()
	_fade.color = Color(0, 0, 0, 0)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade.size = Vector2(6000, 4000)
	layer.add_child(_fade)

	flag = args.find("--selftest")
	if flag >= 0:
		test_mode = true
		current = TitleScene.new()
		add_child(current)
		var st: Node = load("res://scripts/selftest.gd").new()
		add_child(st)
		st.start(args[flag + 1] if args.size() > flag + 1 else "user://shots", args.has("--playthrough"))
		return
	flag = args.find("--perf")
	if flag >= 0:
		test_mode = true
		var g := GameScene.new("normal")
		g.autopilot = true
		current = g
		add_child(current)
		var st: Node = load("res://scripts/selftest.gd").new()
		add_child(st)
		st.perf(g, args[flag + 1] if args.size() > flag + 1 else "user://shots")
		return

	current = TitleScene.new()
	add_child(current)


func go_to(scene: Node) -> void:
	if switching: return
	switching = true
	var tw := create_tween()
	tw.tween_property(_fade, "color:a", 1.0, 0.15)
	tw.tween_callback(func():
		current.queue_free()
		current = scene
		add_child(current))
	tw.tween_property(_fade, "color:a", 0.0, 0.15)
	tw.tween_callback(func(): switching = false)


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_GO_BACK_REQUEST:
			if current and not switching and current.has_method("on_back"): current.on_back()
		NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_APPLICATION_PAUSED:
			Sound.set_background(true)
			if current is GameScene: current.auto_pause()
		NOTIFICATION_APPLICATION_FOCUS_IN, NOTIFICATION_APPLICATION_RESUMED:
			Sound.set_background(false)


## How hard each 30 seconds of the night is, averaged over many bot runs.
func _run_curve(runs: int, flame: String) -> void:
	const SLICES := 12
	var alive_runs := PackedInt32Array(); alive_runs.resize(SLICES)
	var deaths := PackedInt32Array(); deaths.resize(SLICES)
	var light_sum := PackedFloat32Array(); light_sum.resize(SLICES)
	var dmg_sum := PackedFloat32Array(); dmg_sum.resize(SLICES)
	var enemy_sum := PackedFloat32Array(); enemy_sum.resize(SLICES)
	var low_sum := PackedFloat32Array(); low_sum.resize(SLICES)
	var samples := PackedInt32Array(); samples.resize(SLICES)
	var level_sum := PackedFloat32Array(); level_sum.resize(SLICES)
	for r in runs:
		var g := GameScene.new("normal", true, flame)
		var last_slice := -1
		var dmg_at_start := 0.0
		while not g.finished and g.t < 400.0:
			if g.state == GameScene.State.LEVEL_UP: g.choose_option(g.current_options.pick_random())
			g.step(1.0 / 60.0)
			var s := mini(int(g.t / 30.0), SLICES - 1)
			if s != last_slice:
				if last_slice >= 0: dmg_sum[last_slice] += g.damage_taken - dmg_at_start
				dmg_at_start = g.damage_taken
				alive_runs[s] += 1
				last_slice = s
			var frac := g.light / g.max_light
			light_sum[s] += frac
			if frac < 0.3: low_sum[s] += 1.0
			enemy_sum[s] += g.enemies.size()
			level_sum[s] += g.level
			samples[s] += 1
		dmg_sum[last_slice] += g.damage_taken - dmg_at_start
		if not g.won: deaths[last_slice] += 1
		g.free()
	print("flame=%s runs=%d  (per 30 s of night: runs still alive, deaths, avg light, time under 30%% light, hits taken, enemies, level)" % [flame, runs])
	for s in SLICES - 2:
		var n := maxi(1, samples[s])
		print("%s-%s  alive=%2d  deaths=%2d  light=%3d%%  low=%3d%%  hurt/run=%5.1f  enemies=%3d  level=%4.1f" % [
				Data.time_string(s * 30), Data.time_string(s * 30 + 30), alive_runs[s], deaths[s], int(light_sum[s] / n * 100), int(low_sum[s] / n * 100),
				dmg_sum[s] / maxi(1, alive_runs[s]), int(enemy_sum[s] / n), level_sum[s] / n])


func _run_balance(runs: int, flame: String) -> void:
	var times: Array[float] = []
	var total_level := 0
	var total_kills := 0
	var total_dust := 0
	var wins := 0
	var peak := 0
	var start := Time.get_ticks_msec()
	var worst_ms := 0.0
	var steps_total := 0
	for r in runs:
		var g := GameScene.new("normal", true, flame)
		var steps := 0
		while not g.finished and steps < 60 * 400:
			if g.state == GameScene.State.LEVEL_UP: g.choose_option(g.current_options.pick_random())
			var t0 := Time.get_ticks_usec()
			g.step(1.0 / 60.0)
			worst_ms = maxf(worst_ms, (Time.get_ticks_usec() - t0) / 1000.0)
			peak = maxi(peak, g.enemies.size())
			steps += 1
		steps_total += steps
		times.append(g.t)
		total_level += g.level
		total_kills += g.kills
		total_dust += g.earned_stardust()
		if g.won: wins += 1
		g.free()
	times.sort()
	var cpu := (Time.get_ticks_msec() - start) / 1000.0
	print("flame=%s runs=%d wins=%d median=%.0fs min=%.0fs max=%.0fs avgLevel=%.1f avgKills=%d avgStardust=%d peakEnemies=%d cpu=%.1fs avgStepMs=%.2f worstStepMs=%.1f" % [
			flame, runs, wins, times[times.size() / 2], times[0], times[-1], float(total_level) / runs, total_kills / runs, total_dust / runs, peak, cpu, cpu * 1000.0 / steps_total, worst_ms])
