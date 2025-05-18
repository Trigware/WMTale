extends Label

@onready var fade = $CanvasLayer/FadeOverlay
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
		skip_cutscene()
	
func skip_cutscene():
	skipEnabled = false
	fade.show()
	fade.modulate.a = 0
	var tween = create_tween()
	tween.tween_property(fade, "modulate:a", 1, fadeDuration)
	musicPlayer.fade_music(1)
	await tween.finished
	await get_tree().process_frame
	get_tree().change_scene_to_file("res://Scenes/ChooseCharacter.tscn")
