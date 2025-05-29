extends Control

@onready var scrollingBackground = $Background
@onready var lightTexture = $Light
@onready var leafTexture = $Leaf
@onready var textReminder = $"Text Reminder"
@onready var musicNode = $Music
@onready var nameInput = $"Name Input"
@onready var characterAnimations = $"Character Animations"
@onready var bibleTexture = $Bible

const finalYPosition = -1296
const hoverDuration = 2
const hoverDistance = 100

var leafGoingUp = 1
var continuedToNextText = false
var isLeafStoppingToHover = false
var canSelectCharacter = false
var chosenCharacter := PlayableCharacter.xDaForge
var finalLeafRescalePosition = Vector2(537, 460)

const leafShrinkDuration = 2
const leafCharacterSelectDuration = 0.35

var playableCharacters = ["rabbitek", "xdaforge", "gertofin"]

enum PlayableCharacter
{
	Rabbitek = 1,
	xDaForge = 2,
	Gertofin = 3
}

func _ready():
	SaveData.selectedCharacter = ""
	TextSystem.fallbackPreset = TextSystem.Preset.ChooseCharacter
	var empty_style = StyleBoxEmpty.new()
	nameInput.add_theme_stylebox_override("focus", empty_style)
	nameInput.connect("text_submitted", Callable(self, "on_name_submitted"))
	musicNode.finished.connect(loop_audio)
	
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
	TextSystem.print_preset("Díky němu můžeš měnit tento svět.")
	await TextSystem.want_next_text
	TextSystem.print_preset("Protože bez těla nemáš šanci přežít{1}, nějaké si vyber.")
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
	create_tween().tween_property(leafTexture, "position", finalLeafRescalePosition, leafShrinkDuration).set_trans(Tween.TRANS_SINE)
	var rescaleTween = create_tween()
	rescaleTween.tween_property(leafTexture, "scale", Vector2(0.5, 0.5), leafShrinkDuration).set_trans(Tween.TRANS_SINE)
	await rescaleTween.finished
	characterAnimations.summon_characters()

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
	var previousChosenCharacter = chosenCharacter
	
	if Input.is_action_just_pressed("leaf_left") and chosenCharacter != PlayableCharacter.Rabbitek:
		chosenCharacter -= 1
	if Input.is_action_just_pressed("leaf_right") and chosenCharacter != PlayableCharacter.Gertofin:
		chosenCharacter += 1
	if Input.is_action_just_pressed("continue"):
		select_character()
	
	if previousChosenCharacter != chosenCharacter:
		move_leaf_to_chosen_character()

func move_leaf_to_chosen_character():
	if SaveData.selectedCharacter != "": return
	var finalXPosition = 337 * chosenCharacter - 137
	var leafMoveTween = create_tween()
	leafMoveTween.tween_property(leafTexture, "position:x", finalXPosition, leafCharacterSelectDuration).\
	set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	canSelectCharacter = false
	await leafMoveTween.finished
	canSelectCharacter = true

func select_character():
	if SaveData.selectedCharacter != "": return
	var tween = create_tween()
	tween.tween_property(leafTexture, "position:y", 305, 2).set_trans(Tween.TRANS_SINE).\
	set_ease(Tween.EASE_IN_OUT)
	SaveData.selectedCharacter = playableCharacters[chosenCharacter - 1]
	await tween.finished
	TextSystem.print_preset("Napiš, jak ti budou říkat.")
	create_tween().tween_property(nameInput, "modulate:a", 1, 1)
	nameInput.grab_focus()

func on_name_submitted(text):
	nameInput.release_focus()
	var checkedName = text.to_lower()
	var invalidName = false
	TextSystem.overwriteSkippable = true
	if checkedName in playableCharacters:
		if SaveData.selectedCharacter.to_lower() == checkedName:
			TextSystem.overwriteSkippable = false
			TextSystem.print_preset("Zajímavá náhoda...")
			await TextSystem.want_next_text
		else:
			TextSystem.print_preset("To by bylo matoucí!")
			invalidName = true
	elif checkedName == "angryhonzik" or checkedName == "trigware":
		TextSystem.overwriteSkippable = false
		TextSystem.print_preset("Ty píšeš kód, který tvoří tento svět?")
		await TextSystem.want_next_text
	elif checkedName == "wmt" || checkedName == "wise mystical tree":
		TextSystem.print_preset("Mé jméno nosit nebudeš!")
		invalidName = true
	elif text.strip_edges() == "":
		TextSystem.print_preset("Jméno musí obsahovat viditelné symboly.")
		invalidName = true
	elif text.find("{") != -1 or text.find("}") != -1 or text.find("[") != -1 or text.find("]") != -1:
		TextSystem.print_preset("Vyber si jméno bez hranatých a složených závorek.")
		invalidName = true
	
	if invalidName:
		nameInput.text = ""
		nameInput.grab_focus()
		return
	
	TextSystem.overwriteSkippable = false
	SaveData.playerName = text
	on_player_named()

func on_player_named():
	create_tween().tween_property(nameInput, "modulate:a", 0, 1)
	create_tween().tween_property(characterAnimations, "modulate:a", 0, 1)
	var tween = create_tween().tween_property(leafTexture, "position", finalLeafRescalePosition, 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	TextSystem.print_preset("'" + SaveData.playerName + "'...")
	await TextSystem.want_next_text
	show_bible()

func show_bible():
	TextSystem.print_preset("Ještě nám zbývá jedna věc...")
	await TextSystem.want_next_text
	music_tween(-80, 0.5)
	Audio.play_sound("res://Audio/SFX/Bible Appears.mp3")
	create_tween().tween_property(lightTexture, "modulate:a", 1, 1)
	var tween = create_tween().tween_property(bibleTexture, "position:y", 150, 4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	music_tween(0, 0.5)
	TextSystem.print_preset("Tato posvátná kniha je nezbytná k mému daru.")
	await TextSystem.want_next_text
	finish_scene()

func finish_scene():
	TextSystem.print_preset("Jestli jej využiješ k dobru či zlu, je mi jedno.")
	await TextSystem.want_next_text
	TextSystem.print_preset("Chci jen, aby ses zbavil Smurf Catského teroru...")
	await TextSystem.want_next_text
	TextSystem.print_preset("a šíření jejich víry.")
	await TextSystem.want_next_text
	TextSystem.print_preset("...{1}vypadá to, že už máme všechno připravené.")
	await TextSystem.want_next_text
	TextSystem.print_preset("Hodně štěstí!")
	await TextSystem.want_next_text
	TextSystem.clear_text()
	SaveData.choosePlayerSceneFinished = true
	SaveData.save_game()
	music_tween(-80, 3)
	Overlay.change_scene("res://Scenes/Overworld.tscn", 3, 1)

func loop_audio():
	musicNode.play()

func music_tween(final, duration):
	create_tween().tween_property(musicNode, "volume_db", final, duration).set_trans(Tween.TRANS_EXPO)
