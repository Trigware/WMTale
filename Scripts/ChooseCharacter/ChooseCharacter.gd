extends Control

@onready var tree = $SceneElements/Tree
@onready var leaf = $SceneElements/Leaf
@onready var eventsTimer = $SceneElements/EventsTimer
@onready var nameInput = $"SceneElements/Name Input"

const eventDuration = 2
var leafMovementAllowed = false
var playerSelected = false
var playerNameTyped = false
var characterChosen = false
var playerName = ""

var interestingNames := ["rabbitek", "xdaforge", "gertofin"]

signal tween_finished

func _ready():
	leaf.leaf_entered_character_trigger.connect(player_chose_character)
	nameInput.text_submitted.connect(on_name_submited)
	hide_everything()
	eventsTimer.start()
	await eventsTimer.timeout
	show_tree()

func show_tree():
	tree.show()
	transparency_tween(tree, 1)
	await tween_finished
	TextSystem.print_preset("Buď vítán. Zde je tvůj dar. Toto je list, čím budeš měnit stromovský svět!", TextSystem.Preset.ChooseCharacter)
	await TextSystem.text_finished
	leaf_fall()
	
func leaf_fall():
	var tween = create_tween()
	leaf.show()
	tween.tween_property(leaf, "position", Vector2(leaf.position.x, 425), eventDuration).set_trans(Tween.TRANS_SINE)
	await tween.finished
	leafMovementAllowed = true
	TextSystem.print_preset("Ovládej jej pomocí šipek na klávesnici nebo WASD!", TextSystem.Preset.ChooseCharacter)
	await leaf.leaf_moved
	$SceneElements/Music.play()
	TextSystem.print_preset("Vyber si STROMOVCE, potrvrdíš pomocí ENTER když list je nad ním!", TextSystem.Preset.ChooseCharacter)

func transparency_tween(texture, final):
	var tween = create_tween()
	tween.tween_property(texture, "modulate:a", final, eventDuration).set_trans(Tween.TRANS_SINE)
	await tween.finished
	emit_signal("tween_finished")

func hide_everything():
	TextSystem.clear_text()
	tree.modulate.a = 0
	leaf.hide()

func player_chose_character():
	$SceneElements/Rabbitek.modulate = Color.YELLOW if leaf.currentChoice == leaf.TriggerZone.Rabbitek else Color.WHITE
	$SceneElements/xDaForge.modulate = Color.YELLOW if leaf.currentChoice == leaf.TriggerZone.xDaForge else Color.WHITE
	$SceneElements/Gertofin.modulate = Color.YELLOW if leaf.currentChoice == leaf.TriggerZone.Gertofin else Color.WHITE
	nameInput.show()
	if not playerSelected:
		edit_name()
	playerSelected = true

func on_name_submited(text):
	if text.strip_edges() == "":
		edit_name()
		playerNameTyped = false
		TextSystem.print_preset("Prosím zadej jméno!", TextSystem.Preset.ChooseCharacter)
		return
	if not playerNameTyped:
		TextSystem.print_preset("Zmáčkni CTRL a pokračuj dál nebo SHIFT a uprav jméno!", TextSystem.Preset.ChooseCharacter)
	playerNameTyped = true
	nameInput.release_focus()
	leafMovementAllowed = true
	playerName = text

func _process(_delta: float):
	if Input.is_action_just_pressed("edit_name") and not nameInput.has_focus() and not characterChosen: edit_name()
	if Input.is_action_just_pressed("continue_character_select") and not nameInput.has_focus() and not characterChosen:
		end_choose_character_scene()

func edit_name():
	nameInput.clear()
	nameInput.grab_focus()
	leafMovementAllowed = false
	
func end_choose_character_scene():
	leafMovementAllowed = false
	characterChosen = true
	var characterChooseDialog = "Šiř stromovskou víru přes celý národ!"
	var lowerPlayerName = playerName.to_lower()
	if lowerPlayerName in interestingNames:
		characterChooseDialog = "Zajímavá náhoda..."
	TextSystem.print_preset(characterChooseDialog, TextSystem.Preset.ChooseCharacter)
	await TextSystem.text_finished
	var tween = create_tween()
	tween.tween_property($SceneElements, "position", Vector2(0, -700), eventDuration * 4).set_trans(Tween.TRANS_SINE)
	create_tween().tween_property($SceneElements, "modulate:a", 0, eventDuration * 2).set_trans(Tween.TRANS_SINE)
	create_tween().tween_property($SceneElements/Music, "volume_db", -80.0, eventDuration * 4).set_trans(Tween.TRANS_EXPO)
	TextSystem.fade_text(eventDuration * 2)
