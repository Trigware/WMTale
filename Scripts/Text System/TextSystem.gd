extends Control
	
@onready var textNode = $CanvasLayer/Text
@onready var typewritterTimer = $TypewritterTimer

var currentCharacterIndex := 0
var printedText = ""
var fontSize = 0

signal text_finished

enum Preset
{
	LegendSmallPanel,
	LegendBigPanel,
	ChooseCharacter
}

var TextConfigurations = {
	Preset.LegendSmallPanel: {
		"speed": 0.08,
		"font_size": 48,
		"position": Vector2(255, 385),
		"line_length": 650
	},
	Preset.LegendBigPanel: {
		"speed": 0.08,
		"font_size": 48,
		"position": Vector2(255, 540),
		"line_length": 650
	},
	Preset.ChooseCharacter: {
		"speed": 0.05,
		"font_size": 32,
		"position": Vector2(255, 610),
		"center_align": true
	}
}

func _ready():
	typewritterTimer.timeout.connect(print_next_char)

func print_text(text, speed, textSize, textPosition, lineLength, centerAlign):
	fontSize = textSize
	textNode.position = textPosition
	textNode.clear()
	printedText = split_text_by_lines(text, lineLength)
	
	if centerAlign:
		align_to_center(text)
	currentCharacterIndex = 0
	if speed > 0:
		typewritterTimer.start(speed)
		return
	
	textNode.text = get_text_with_size(printedText)
	emit_signal("text_finished")

func print_preset(text, preset: Preset):
	var config = TextConfigurations[preset]
	print_text(
		text,
		config.speed,
		config.font_size,
		config.position,
		config.get("line_length", 0),
		config.get("center_align", false)
	)

func print_next_char():
	if currentCharacterIndex < printedText.length():
		textNode.append_text(get_text_with_size(printedText[currentCharacterIndex]))
		currentCharacterIndex += 1
		return
	typewritterTimer.stop()
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
	var centerX = 1090 / 2.0
	textNode.position.x = centerX - get_text_width(text) / 2

func fade_text(duration):
	var tween = create_tween()
	tween.tween_property($CanvasLayer/Text, "modulate:a", 0, duration)
	await tween.finished
	clear_text()	
