extends Control
	
@onready var textNode = $CanvasLayer/Text
@onready var typewritterTimer = $TypewritterTimer
@onready var textboxNode = $CanvasLayer/Textbox
@onready var choicerNode = $CanvasLayer/Textbox/Choicer

@onready var leafNode = $CanvasLayer/Textbox/Choicer/Leaf
@onready var choiceNodes := {
	Vector2(-1, 0): $"CanvasLayer/Textbox/Choicer/Choice A",
	Vector2(+1, 0): $"CanvasLayer/Textbox/Choicer/Choice B",
	Vector2(0, -1): $"CanvasLayer/Textbox/Choicer/Choice C",
	Vector2(0, +1): $"CanvasLayer/Textbox/Choicer/Choice D"
}

var fallbackPreset: Preset
const standardScreenWidth = 1152
const choicerInputDuration = 0.5
var currentCharacterIndex := 0
var printedText = ""
var fontSize = 0

var characterDelays := {}
var delayed = false
var textCanBeSkipped = false
var originalSpeed
var currentTextAudio : AudioStream
var currentPitchRange = 0

var overwriteSkippable = false
var lockAction = false
var textFinished = false
var inChoicer = false
var disableChoicerInputs = false
var choiceList := []
var defaultLeafPosition := Vector2(105, 29)
var previousChoiceDirection := Vector2.ZERO
var choiceNodeIndex := -1
var lastChoiceText := ""
var currentOverlappingSoundsValue := false
var canInteract = false

signal text_finished
signal want_next_text
signal submitted_choice

enum Preset
{
	Fallback,
	LegendSmallPanel,
	LegendBigPanel,
	ChooseCharacter,
	RegularDialog
}

var TextConfigurations = {
	Preset.LegendSmallPanel: {
		"position": Vector2(255, 350),
		"line_length": 650,
		"allow_text_skip": false
	},
	Preset.LegendBigPanel: {
		"position": Vector2(255, 540),
		"line_length": 650,
		"allow_text_skip": false
	},
	Preset.ChooseCharacter: {
		"position": Vector2(255, 590),
		"center_align": true,
		"talk_audio": load("res://Audio/Talk/WMT.mp3"),
		"pitch_range": 0.2,
		"overlap_audio": true
	},
	Preset.RegularDialog: {
		"talk_audio": load("res://Audio/Talk/Default.mp3"),
		"pitch_range": 0.15,
		"font_size": 44,
		"textbox": true,
		"position": Vector2(150, 405),
		"speed": 1.0/30,
		"line_length": 850
	}
}

func _ready():
	typewritterTimer.timeout.connect(print_next_char)
	want_next_text.connect(on_wanting_new_text)

func print_text(text, speed, textSize, textPosition, lineLength, centerAlign, allowTextSkip, talkAudio, pitchRange, textbox, overlappingSounds):
	lockAction = true
	if overwriteSkippable:
		allowTextSkip = false
	delayed = false
	textFinished = false
	fontSize = textSize
	
	textNode.scale = Vector2(fontSize, fontSize) / 48
	textNode.position = textPosition
	textNode.text = ""
	originalSpeed = speed
	currentTextAudio = talkAudio
	currentPitchRange = pitchRange
	textboxNode.visible = textbox
	currentOverlappingSoundsValue = overlappingSounds
	
	var regularText = record_character_delays(text)
	printedText = split_text_by_lines(regularText, lineLength)
	textCanBeSkipped = allowTextSkip
	if centerAlign:
		align_to_center(regularText)
	
	currentCharacterIndex = 0
	if speed > 0:
		typewritterTimer.start(speed)
		return
	
	textNode.text = printedText
	textFinished = true
	emit_signal("text_finished")

func print_preset(text, preset: Preset = Preset.Fallback):
	if preset == Preset.Fallback:
		preset = fallbackPreset
	var config = TextConfigurations[preset]
	print_text(
		text,
		config.get("speed", 0.08),
		config.get("font_size", 48),
		config.get("position", Vector2(0, 0)),
		config.get("line_length", 0),
		config.get("center_align", false),
		config.get("allow_text_skip", true),
		config.get("talk_audio", null),
		config.get("pitch_range", 0),
		config.get("textbox", false),
		config.get("overlap_audio", false)
	)

func print_next_char():
	if delayed: return
	var delay = characterDelays.get(currentCharacterIndex, 0)
	if delay > 0:
		delayed = true
		await get_tree().create_timer(delay).timeout
		delayed = false
	if currentOverlappingSoundsValue:
		Audio.play_stream(currentTextAudio, currentPitchRange)
	else:
		Audio.play_awaited_stream(currentTextAudio, currentPitchRange)
	if currentCharacterIndex < printedText.length():
		textNode.text += printedText[currentCharacterIndex]
		currentCharacterIndex += 1
		return
	typewritterTimer.stop()
	textCanBeSkipped = false
	textFinished = true
	emit_signal("text_finished")

func split_text_by_lines(text, lineLength) -> String:
	if lineLength == 0: return text
	var paragraphs := str(text).split("\n")
	var wrapped_text := ""

	for paragraph in paragraphs:
		var words := paragraph.split(" ")
		var line := ""
		
		for word in words:
			var currentLine = line + ("" if line == "" else " ") + word
			var currentWidth = get_text_width(currentLine)
			
			if currentWidth > lineLength and line != "":
				wrapped_text += line + "\n"
				line = word
			else:
				line = currentLine
		
		wrapped_text += line + "\n"

	return wrapped_text.strip_edges()

func clear_text():
	textNode.text = ""
	typewritterTimer.stop()
	lockAction = false
	inChoicer = false
	textboxNode.hide()
	choicerNode.hide()
	if previousChoiceDirection in choiceNodes:
		choiceNodes[previousChoiceDirection].modulate = Color.WHITE
	leafNode.modulate.a = 1
	
func get_text_width(text) -> float:
	var font = textNode.get_theme_font("normal_font")
	return (font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fontSize)).x

func align_to_center(text):
	var centerX = standardScreenWidth / 2.0
	textNode.position.x = centerX - get_text_width(text) / 2

func fade_text(duration):
	var tween = create_tween()
	tween.tween_property($CanvasLayer/Text, "modulate:a", 0, duration)
	await tween.finished
	clear_text()

func record_character_delays(text) -> String:
	characterDelays.clear()
	var inBrackets = false
	var bracketContent = ""
	var currentPrintedCharacter = 0
	var latestDelay = 0
	var normalText = ""
	
	for letter in text:
		match letter:
			"{":
				bracketContent = ""
				inBrackets = true
			"}":
				if inBrackets:
					inBrackets = false
					latestDelay += float(bracketContent)
					characterDelays.set(currentPrintedCharacter, latestDelay)
			_:
				bracketContent += letter
				if not inBrackets:
					currentPrintedCharacter += 1
					latestDelay = 0
					normalText += letter
	
	return normalText

func skip_text():
	if not textCanBeSkipped: return
	textNode.text = printedText
	currentCharacterIndex = printedText.length()

func _unhandled_input(_event: InputEvent):
	if (Input.is_action_just_pressed("continue") or Input.is_action_pressed("skip_text")) and textFinished:
		emit_signal("want_next_text")
	if Input.is_action_just_pressed("continue") and inChoicer:
		on_choice_decided()
	if Input.is_action_just_pressed("reveal_text") or Input.is_action_pressed("skip_text"):
		skip_text()
	if inChoicer:
		handle_choicer_inputs()

func print_localization(text_key, variables: Array = [], preset: Preset = Preset.Fallback):
	print_preset(Localization.get_text(text_key, variables), preset)

func on_wanting_new_text():
	textFinished = false
	if inChoicer: return
	textboxNode.hide()
	lockAction = false
	clear_text()

func print_sequence_no_variables(sequence: Array[String]):
	for text in sequence:
		print_localization(text)
		await want_next_text

func give_choice(choiceAText, choiceBText, choiceCText = "", choiceDText = ""):
	previousChoiceDirection = Vector2.ZERO
	lockAction = true
	inChoicer = true
	textboxNode.show()
	choicerNode.show()
	leafNode.position = defaultLeafPosition
	
	choiceList = [choiceAText, choiceBText, choiceCText, choiceDText]
	choiceNodes[Vector2(-1, 0)].text = choiceAText
	choiceNodes[Vector2(+1, 0)].text = choiceBText
	choiceNodes[Vector2(0, -1)].text = choiceCText
	choiceNodes[Vector2(0, +1)].text = choiceDText
	await submitted_choice

func print_wait(text, preset: Preset = Preset.Fallback):
	print_preset(text, preset)
	await want_next_text

func print_wait_localization(text, variables: Array = [], preset: Preset = Preset.Fallback):
	print_localization(text, variables, preset)
	await want_next_text

func handle_choicer_inputs():
	if disableChoicerInputs: return
	var direction := Vector2(0, 0)
	if Input.is_action_just_pressed("move_left") and choiceList[0] != "":
		direction.x = -1
	if Input.is_action_just_pressed("move_right") and choiceList[1] != "":
		direction.x = +1
	if Input.is_action_just_pressed("move_up") and choiceList[2] != "":
		direction.y = -1
	if Input.is_action_just_pressed("move_down") and choiceList[3] != "":
		direction.y = +1
	if direction != Vector2.ZERO: move_choicer_leaf(direction)

func move_choicer_leaf(direction):
	var finalPosition = Vector2(defaultLeafPosition.x + direction.x * 50, defaultLeafPosition.y + direction.y * 10)
	var usedDuration = choicerInputDuration
	if direction.x == 0 and defaultLeafPosition == leafNode.position:
		usedDuration /= 2
	var positionTween = create_tween().tween_property(leafNode, "position", finalPosition, usedDuration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	choicer_modulation_tweens(finalPosition, direction, usedDuration)
	disableChoicerInputs = true
	await positionTween.finished
	disableChoicerInputs = false
	previousChoiceDirection = direction

func choicer_modulation_tweens(finalPosition, direction, usedDuration):
	if finalPosition == leafNode.position: return
	Audio.play_sound("res://Audio/SFX/Changed Choice.mp3", 0.1)
	create_tween().tween_property(choiceNodes[direction], "modulate", Color.WEB_GREEN, usedDuration)
	if defaultLeafPosition == leafNode.position:
		create_tween().tween_property(leafNode, "modulate:a", 0, usedDuration)
		return
	create_tween().tween_property(choiceNodes[previousChoiceDirection], "modulate", Color.WHITE, usedDuration)
	var showtween = create_tween().tween_property(leafNode, "modulate:a", 1, usedDuration/2)
	await showtween.finished
	create_tween().tween_property(leafNode, "modulate:a", 0, usedDuration/2)

func on_choice_decided():
	if disableChoicerInputs: return
	choiceNodeIndex = choiceNodes.keys().find(previousChoiceDirection)
	if choiceNodeIndex == -1: return
	lastChoiceText = choiceList[choiceNodeIndex]
	clear_text()
	emit_signal("submitted_choice")
