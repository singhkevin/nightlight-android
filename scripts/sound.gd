extends Node
## Plays the sound effects and music copied from the Mac game.

const VARIANTS := {
	"shoot": 4, "hit": 4, "kill": 5, "hurt": 1, "nova": 1, "zap": 3, "star": 3, "bomb": 1, "spit": 3, "button": 1, "hover": 1,
	"levelup": 1, "warn": 1, "boss": 1, "bossdie": 1, "revive": 1, "die": 1, "dawn": 1, "buy": 1,
	"ember0": 1, "ember1": 1, "ember2": 1, "ember3": 1, "ember4": 1, "ember5": 1, "ember6": 1, "ember7": 1,
}

var enabled := true
var _streams := {}
var _players: Array[AudioStreamPlayer] = []
var _next := 0
var _last := {}
var _music: AudioStreamPlayer
var _ready_done := false


func start() -> void:
	if _ready_done or not enabled: return
	_ready_done = true
	for name in VARIANTS:
		var list := []
		for i in VARIANTS[name]:
			list.append(load("res://assets/sfx/%s_%d.wav" % [name, i]))
		_streams[name] = list
	for i in 14:
		var p := AudioStreamPlayer.new()
		add_child(p)
		_players.append(p)
	_music = AudioStreamPlayer.new()
	add_child(_music)
	var m: AudioStreamWAV = load("res://assets/music.wav")
	m.loop_mode = AudioStreamWAV.LOOP_FORWARD
	m.loop_begin = 0
	m.loop_end = int(m.get_length() * m.mix_rate)
	_music.stream = m
	AudioServer.set_bus_volume_linear(0, 0.8)
	apply_mute()


var in_background := false


func apply_mute() -> void:
	AudioServer.set_bus_mute(0, Save.d.muted or in_background)


## A call, the lock screen or another app: stop the music and every effect at once.
func set_background(bg: bool) -> void:
	in_background = bg
	apply_mute()
	if _music:
		_music.stream_paused = bg
	if bg:
		for p in _players:
			p.stop()


func toggle_mute() -> void:
	Save.d.muted = not Save.d.muted
	Save.write()
	apply_mute()


func start_music(volume := 0.5) -> void:
	if not enabled: return
	start()
	_music.volume_linear = volume
	if not _music.playing: _music.play()


func set_music_volume(v: float) -> void:
	if _music: _music.volume_linear = v


func play(name: String, volume := 1.0, min_gap := 0.04) -> void:
	if not _ready_done or not enabled or Save.d.muted: return
	var now := Time.get_ticks_msec() / 1000.0
	if _last.has(name) and now - _last[name] < min_gap: return
	_last[name] = now
	var p := _players[_next]
	_next = (_next + 1) % _players.size()
	p.stream = _streams[name].pick_random()
	p.volume_linear = volume
	p.play()
