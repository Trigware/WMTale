extends Control

@onready var scrollingBackground = $Background
@onready var lightTexture = $Light
@onready var leafTexture = $Leaf
@onready var textReminder = $"Text Reminder"

const finalYPosition = -1296
const hoverDuration = 2
const hoverDistance = 100

var leafGoingUp = 1
var continuedToNextText = false
var isLeafStoppingToHover = false
var canSelectCharacter = false
var chosenCharacter := PlayableCharacter.NotChosen

const leafShrinkDuration = 2
const leafCharacterSelectDuration = 0.35
const leafSelectUpDistance = 100

enum PlayableCharacter
{
	NotChosen = 0,
	Rabbitek = 1,
	xDaForge = 2,
	Gertofin = 3
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
	Audio.play_sound("res://Audio/Music/Who is YOU anyway.mp3")
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
		if isLeafStoppingToHover:
			break
	create_tween().tween_property(leafTexture, "position", Vector2(leafTexture.position.x + 32, 460), leafShrinkDuration).set_trans(Tween.TRANS_SINE)
	var rescaleTween = create_tween()
	rescaleTween.tween_property(leafTexture, "scale", Vector2(0.5, 0.5), leafShrinkDuration).set_trans(Tween.TRANS_SINE)
	await rescaleTween.finished
	canSelectCharacter = true
	TextSystem.print_preset("A proto si musíš vybrat tvé tělo.")

func check_if_not_responding():
	await get_tree().create_timer(3).timeout
	if not continuedToNextText:
		create_tween().tween_property(textReminder, "modulate:a", 1, 1)

func show_characters():
	create_tween().tween_property(lightTexture, "modulate:a", 0, 2)
	isLeafStoppingToHover = true

func _unhandled_input(_event: InputEvent):
	handle_character_selection()

func handle_character_selection():
	if not canSelectCharacter: return
	var characterNotChosen = chosenCharacter == PlayableCharacter.NotChosen
	var previousChosenCharacter = chosenCharacter
	if Input.is_action_just_pressed("leaf_up") and characterNotChosen:
		chosenCharacter = PlayableCharacter.xDaForge
	if Input.is_action_just_pressed("leaf_left") and chosenCharacter != PlayableCharacter.Rabbitek:
		chosenCharacter = PlayableCharacter.Rabbitek if characterNotChosen else chosenCharacter - 1
	if Input.is_action_just_pressed("leaf_right") and chosenCharacter != PlayableCharacter.Gertofin:
		chosenCharacter = PlayableCharacter.Gertofin if characterNotChosen else chosenCharacter + 1
	if previousChosenCharacter != chosenCharacter:
		move_leaf_to_chosen_character()
	if Input.is_action_just_pressed("continue") and not characterNotChosen:
		select_character()
	
func move_leaf_to_chosen_character():
	var finalPosition = Vector2(337 * chosenCharacter - 137, 400)
	var leafMoveTween = create_tween()
	leafMoveTween.tween_property(leafTexture, "position", finalPosition, leafCharacterSelectDuration).\
	set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	canSelectCharacter = false
	await leafMoveTween.finished
	canSelectCharacter = true

func select_character():
	var tween = create_tween()
	tween.tween_property(leafTexture, "position:y", leafTexture.position.y - leafSelectUpDistance, 2).set_trans(Tween.TRANS_SINE).\
	set_ease(Tween.EASE_IN_OUT)
	SaveData.name = "!!!"
