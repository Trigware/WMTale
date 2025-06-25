extends Label

@onready var musicPlayer = get_node("/root/Legend/Music")

var skipEnabled := false
const fadeDuration = 0.75

func _ready():
	text = Localization.get_text("legend_skip_cutscene")
	modulate.a = 0
	$SkipTimer.start()
	await $SkipTimer.timeout
	skipEnabled = true
	fade_label(1)

func fade_label(final):
	create_tween().tween_property(self, "modulate:a", final, fadeDuration)

func _process(delta):
	if skipEnabled && Input.is_action_pressed("continue"):
		end_cutscene()
	
func end_cutscene():
	skipEnabled = false
	musicPlayer.fade_music(1)
	SaveData.allow_game_load = true
	Overlay.change_scene("res://Scenes/ChooseCharacter.tscn", 1, 2, 1.5)
