extends Control
	
@onready var textNode = $CanvasLayer/Text
@onready var typewritterTimer = $TypewritterTimer

var fallbackPreset: Preset
const standardScreenWidth = 1152
var currentCharacterIndex := 0
var printedText = ""
var fontSize = 0
var characterDelays := {}
var delayed = false
var textCanBeSkipped = false
var originalSpeed

signal text_finished
signal want_next_text

enum Preset
{
	Fallback,
	LegendSmallPanel,
	LegendBigPanel,
	ChooseCharacter
}

var TextConfigurations = {
	Preset.LegendSmallPanel: {
		"font_size": 48,
		"position": Vector2(255, 350),
		"line_length": 650,
		"allow_text_skip": false
	},
	Preset.LegendBigPanel: {
		"font_size": 48,
		"position": Vector2(255, 540),
		"line_length": 650,
		"allow_text_skip": false
	},
	Preset.ChooseCharacter: {
		"font_size": 48,
		"position": Vector2(255, 590),
		"center_align": true
	}
}

func _ready():
	typewritterTimer.timeout.connect(print_next_char)

func print_text(text, speed, textSize, textPosition, lineLength, centerAlign, allowTextSkip):
	delayed = false
	fontSize = textSize
	textNode.position = textPosition
	textNode.clear()
	originalSpeed = speed
	
	var regularText = record_character_delays(text)
	printedText = split_text_by_lines(regularText, lineLength)
	textCanBeSkipped = allowTextSkip
	if centerAlign:
		align_to_center(regularText)
	
	currentCharacterIndex = 0
	if speed > 0:
		typewritterTimer.start(speed)
		return
	
	textNode.text = get_text_with_size(printedText)
	emit_signal("text_finished")

func print_preset(text, preset: Preset = Preset.Fallback):
	if preset == Preset.Fallback:
		preset = fallbackPreset
	var config = TextConfigurations[preset]
	print_text(
		text,
		config.get("speed", 0.08),
		config.font_size,
		config.position,
		config.get("line_length", 0),
		config.get("center_align", false),
		config.get("allow_text_skip", true)
	)

func print_next_char():
	if delayed: return
	var delay = characterDelays.get(currentCharacterIndex, 0)
	if delay > 0:
		delayed = true
		await get_tree().create_timer(delay).timeout
		delayed = false
	if currentCharacterIndex < printedText.length():
		textNode.append_text(get_text_with_size(printedText[currentCharacterIndex]))
		currentCharacterIndex += 1
		return
	typewritterTimer.stop()
	textCanBeSkipped = false
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
	textNode.clear()
	typewritterTimer.stop()

func get_text_with_size(text) -> String:
	return "[font_size=" + str(fontSize) + "]" + text + "[/font_size]"
	
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
	textNode.text = get_text_with_size(printedText)
	currentCharacterIndex = printedText.length()

func _unhandled_input(_event: InputEvent):
	if (Input.is_action_just_pressed("continue") or Input.is_action_pressed("skip_text")) and typewritterTimer.is_stopped():
		emit_signal("want_next_text")
	if Input.is_action_just_pressed("reveal_text") or Input.is_action_pressed("skip_text"):
		skip_text()
