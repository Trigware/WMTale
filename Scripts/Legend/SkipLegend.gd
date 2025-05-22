extends Label

@onready var musicPlayer = get_node("/root/Legend/Music")

var skipEnabled := false
const fadeDuration = 0.75

func _ready():
	modulate.a = 0
	$SkipTimer.start()
	await $SkipTimer.timeout
	skipEnabled = true
	fade_label(1)

func fade_label(final):
	create_tween().tween_property(self, "modulate:a", final, fadeDuration)

func _unhandled_input(event: InputEvent):
	if skipEnabled && event.is_action("skip_legend"):
		end_cutscene()
	
func end_cutscene():
	skipEnabled = false
	musicPlayer.fade_music(1)
	Overlay.change_scene("res://Scenes/ChooseCharacter.tscn", 1, 2, 1.5)
