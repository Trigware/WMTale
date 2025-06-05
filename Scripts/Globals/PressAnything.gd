extends Control

@onready var pressAnythingLabel = $PressButton
@onready var versionNumber = $Version

const transparency_duration = 2
var startingGame = false

func _ready():
	pressAnythingLabel.text = Localization.get_text("logo_press_anything")
	versionNumber.text = Localization.get_text("logo_version_number")
	var init_tween = create_tween().tween_property(self, "modulate:a", 1, transparency_duration)\
		.set_ease(Tween.EASE_IN_OUT)\
		.set_trans(Tween.TRANS_SINE)
	await init_tween
	await get_tree().create_timer(1.5).timeout
	tween_transparency(0)

func _process(_delta: float):
	if Input.is_anything_pressed():
		startingGame = true
		Overlay.change_scene("res://Scenes/Legend.tscn")

func tween_transparency(final):
	var tween = create_tween().tween_property(pressAnythingLabel, "modulate:a", final, transparency_duration)\
		.set_ease(Tween.EASE_IN_OUT)\
		.set_trans(Tween.TRANS_SINE)
	await tween.finished
	var nextFinal = 0
	if final == 0: nextFinal = 1
	if startingGame: return
	tween_transparency(nextFinal)
