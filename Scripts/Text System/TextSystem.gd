extends Control
	
@onready var textNode = $CanvasLayer/Text
@onready var typewritterTimer = $TypewritterTimer
@onready var textboxNode = $CanvasLayer/Textbox
@onready var choicerNode = $CanvasLayer/Textbox/Choicer

@onready var choicer_leaf = $CanvasLayer/Textbox/Choicer/Leaf
@onready var waitLeaf = $"CanvasLayer/Wait Leaf"
@onready var choice_label_options := {
	Vector2.LEFT: $"CanvasLayer/Textbox/Choicer/Choice A",
	Vector2.RIGHT: $"CanvasLayer/Textbox/Choicer/Choice B",
	Vector2.UP: $"CanvasLayer/Textbox/Choicer/Choice C",
	Vector2.DOWN: $"CanvasLayer/Textbox/Choicer/Choice D"
}

@onready var true_text_node = textNode
@onready var true_outlined_text = $"CanvasLayer/Outlined Text"

const standardScreenWidth = 1152
var currentCharacterIndex := 0
var printedText = ""
var fontSize = 0

var character_delays := {}
var character_colors := {}

var delayed = false
var currentColor := "#FFFFFF"
var textCanBeSkipped = false
var originalSpeed
var currentTextAudio : AudioStream
var currentPitchRange = 0

var overwriteSkippable = false
var lockAction = false
var v_text_finished = false
var in_choicer = false
var currentOverlappingSoundsValue := false
var canInteract = true
var init_color
var end_latest_text_automatically := false
var end_latest_text_externally := false
var current_line_choicer = false

const default_pause_duration := 0.5

signal text_finished
signal want_next_text
signal want_choicer

func _ready():
	typewritterTimer.timeout.connect(print_next_char)
	want_next_text.connect(on_wanting_new_text)
	text_finished.connect(show_wait_leaf)
	PresetSystem.preset_variations()

func print_text(text, speed, textSize, textPosition, lineLength,
				centerAlign, allowTextSkip, talkAudio, pitchRange,
				textbox, overlappingSounds, outline, initial_color,
				end_automatically, end_externally):
	Player.node.animationNode.stop()
	lockAction = true
	if overwriteSkippable:
		allowTextSkip = false
	delayed = false
	v_text_finished = false
	fontSize = textSize
	textNode.modulate.a = 1
	if outline: textNode = true_outlined_text
	else: textNode = true_text_node
	
	end_latest_text_automatically = end_automatically
	end_latest_text_externally = end_externally
	init_color = initial_color
	currentColor = TextParser.color_to_hex(initial_color)
	textNode.scale = Vector2(fontSize, fontSize) / 48
	textNode.position = textPosition
	textNode.text = ""
	originalSpeed = speed
	currentTextAudio = talkAudio
	currentPitchRange = pitchRange
	textboxNode.visible = textbox
	currentOverlappingSoundsValue = overlappingSounds
	
	var regularText = TextParser.record_control_text(text)
	printedText = split_text_by_lines(regularText, lineLength)
	textCanBeSkipped = allowTextSkip
	if centerAlign:
		align_to_center(regularText)
	
	currentCharacterIndex = 0
	if speed > 0 and regularText != "":
		typewritterTimer.start(speed)
		return
	
	textNode.text = printedText
	await give_choice_from_print_text(regularText == "")

func give_choice_from_print_text(empty_text := false):
	if ChoicerSystem.choicer_options == {}: return
	show_wait_leaf()
	current_line_choicer = true
	if not empty_text:
		await want_choicer
	TextMethods.clear_text()
	await ChoicerSystem.give_choice()
	finish_text()
	emit_signal("want_next_text")
	current_line_choicer = false

func skip_text():
	if not textCanBeSkipped: return
	textNode.text = add_color_to_text(printedText)
	currentCharacterIndex = printedText.length()

func finish_text():
	v_text_finished = true
	emit_signal("text_finished")

func on_wanting_new_text():
	v_text_finished = false
	if ChoicerSystem.in_choicer: return
	textboxNode.hide()
	lockAction = false
	TextMethods.clear_text()

func show_wait_leaf():
	if textboxNode.visible:
		waitLeaf.show()

func print_next_char():
	if delayed: return
	var delay = character_delays.get(currentCharacterIndex, 0)
	currentColor = character_colors.get(currentCharacterIndex, currentColor)
	if delay > 0:
		delayed = true
		await get_tree().create_timer(delay).timeout
		delayed = false
	if currentOverlappingSoundsValue:
		Audio.play_stream(currentTextAudio, currentPitchRange)
	else:
		Audio.play_awaited_stream(currentTextAudio, currentPitchRange)
	if currentCharacterIndex < printedText.length():
		textNode.text += "[color=" + currentColor + "]" + printedText[currentCharacterIndex] + "[/color]"
		currentCharacterIndex += 1
		return
		
	typewritterTimer.stop()
	textCanBeSkipped = false
	
	await give_choice_from_print_text()
	finish_text()
	if end_latest_text_automatically:
		emit_signal("want_next_text")

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

func get_text_width(text) -> float:
	var font = textNode.get_theme_font("normal_font")
	return (font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fontSize)).x

func align_to_center(text):
	var centerX = standardScreenWidth / 2.0
	textNode.position.x = centerX - get_text_width(text) / 2

func add_color_to_text(text) -> String:
	var resultText = ""
	var addFuncCurrentColor = init_color
	if init_color is Color:
		addFuncCurrentColor = TextParser.color_to_hex(init_color)
	for i in range(text.length()):
		var ch = text[i]
		addFuncCurrentColor = character_colors.get(i, addFuncCurrentColor)
		resultText += "[color=" + addFuncCurrentColor + "]" + ch + "[/color]"
	return resultText

func _unhandled_input(_event: InputEvent):
	if end_latest_text_externally: return
	var dialog_continuation_allowed = (Input.is_action_just_pressed("continue") or Input.is_action_pressed("skip_text")) and (v_text_finished or current_line_choicer)
	if dialog_continuation_allowed:
		var emitted_signal = "want_next_text"
		if current_line_choicer: emitted_signal = "want_choicer"
		emit_signal(emitted_signal)
	if Input.is_action_just_pressed("continue") and ChoicerSystem.in_choicer:
		ChoicerSystem.on_choice_decided()
	if Input.is_action_just_pressed("move_fast") or Input.is_action_pressed("skip_text"):
		skip_text()
	if ChoicerSystem.in_choicer:
		ChoicerSystem.handle_choicer_inputs()
