extends AudioStreamPlayer

@onready var musicTimer = $MusicTimer
var cutsceneOver = false
const fadeTime = 5

func _ready():
	play()
	musicTimer.start(stream.get_length() - fadeTime)
	await musicTimer.timeout
	fade_music(fadeTime * 2)

func fade_music(duration):
	var tween = create_tween()
	tween.tween_property(self, "volume_db", -80.0, duration).set_trans(Tween.TRANS_EXPO)
	cutsceneOver = true
