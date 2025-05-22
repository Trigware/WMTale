extends Control

@onready var scrollingBackground = $Background
@onready var lightTexture = $Light
@onready var leafTexture = $Leaf
@onready var textReminder = $"Text Reminder"
@onready var musicNode = $Music

const finalYPosition = -1296
const hoverDuration = 2
const hoverDistance = 100

var leafGoingUp = 1
var continuedToNextText = false
var leafTweenPending = false
var chosenCharacter := PlayableCharacters.NotChosen

enum PlayableCharacters
{
	NotChosen,
	Rabbitek,
	XDaForge,
	Gertofin
}

func _ready():
	TextSystem.fallbackPreset = TextSystem.Preset.ChooseCharacter
	TextSystem.clear_text()
	var tween = create_tween()
	tween.tween_property(scrollingBackground, "position:y", finalYPosition, 8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	await get_tree().create_timer(1.5).timeout
	summon_leaf()

func summon_leaf():
	Audio.play_sound("res://Audio/SFX/Light Switch.mp3")
	lightTexture.show()
	await get_tree().create_timer(0.5).timeout
	var tween = create_tween()
	tween.tween_property(leafTexture, "position:y", 250, 2.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	TextSystem.print_preset("Zde je můj dar.")
	await TextSystem.text_finished
	
	check_if_not_responding()
	leaf_hover()
	musicNode.play()
	await TextSystem.want_next_text
	create_tween().tween_property(textReminder, "modulate:a", 0, 1)
	continuedToNextText = true
	TextSystem.print_preset("Přes něj můžeš měnit tento svět.")
	await TextSystem.want_next_text
	TextSystem.print_preset("Avšak bez těla...{1} zde přežít nemůžeš.")
	await TextSystem.want_next_text
	TextSystem.clear_text()
	show_characters()

func leaf_hover():
	while true:
		var tween = create_tween().tween_property(
			leafTexture, "position:y", leafTexture.position.y - hoverDistance * leafGoingUp, hoverDuration).\
			set_trans(Tween.TRANS_SINE)
		await tween.finished
		leafGoingUp *= -1
		if leafTweenPending:
			break
	create_tween().tween_property(leafTexture, "position", Vector2(leafTexture.position.x + 32, 460), 2).set_trans(Tween.TRANS_SINE)
	create_tween().tween_property(leafTexture, "scale", Vector2(0.5, 0.5), 2).set_trans(Tween.TRANS_SINE)

func check_if_not_responding():
	await get_tree().create_timer(3).timeout
	if not continuedToNextText:
		create_tween().tween_property(textReminder, "modulate:a", 1, 1)

func show_characters():
	create_tween().tween_property(lightTexture, "modulate:a", 0, 2)
	leafTweenPending = true

func _process(_delta: float):
	print(chosenCharacter)
