extends Control
	
@onready var textNode = $CanvasLayer/Text
@onready var typewritterTimer = $TypewritterTimer
@onready var textboxNode = $CanvasLayer/Textbox
@onready var choicerNode = $CanvasLayer/Textbox/Choicer

@onready var leafNode = $CanvasLayer/Textbox/Choicer/Leaf
@onready var waitLeaf = $"CanvasLayer/Wait Leaf"
@onready var choiceNodes := {
	Vector2(-1, 0): $"CanvasLayer/Textbox/Choicer/Choice A",
	Vector2(+1, 0): $"CanvasLayer/Textbox/Choicer/Choice B",
	Vector2(0, -1): $"CanvasLayer/Textbox/Choicer/Choice C",
	Vector2(0, +1): $"CanvasLayer/Textbox/Choicer/Choice D"
}

@onready var true_text_node = textNode
@onready var true_outlined_text = $"CanvasLayer/Outlined Text"

var fallbackPreset: Preset
const standardScreenWidth = 1152
const choicerInputDuration = 0.5
const max_random_sequences = 20
var currentCharacterIndex := 0
var printedText = ""
var fontSize = 0

var characterDelays := {}
var characterColors := {}

var delayed = false
var currentColor := "#FFFFFF"
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
var canInteract = true
var init_color
var end_latest_text_automatically := false
var end_latest_text_externally := false

const default_pause_duration := 0.5

signal text_finished
signal want_next_text
signal submitted_choice
signal sequence_finished

enum Preset
{
	Fallback,
	LegendSmallPanel,
	LegendBigPanel,
	ChooseCharacter,
	RegularDialog,
	OverworldTreeTalk,
	GameOver,
	FirstGameOver,
	TreeTextCutoff,
	CharacterDialog
}

enum Property
{
	VectorPosition,
	PositionX,
	PositionY,
	LineLength,
	Speed,
	AllowTextSkip,
	CenterAlign,
	TalkAudio,
	PitchRange,
	OverlapAudio,
	FontSize,
	Textbox,
	Outline,
	InitialColor,
	EndAutomatically,
	EndExternally
}

@onready var TextConfigurations = {
	Preset.LegendSmallPanel: {
		Property.PositionX: 255,
		Property.PositionY: 350,
		Property.LineLength: 650,
		Property.Speed: 0.08,
		Property.AllowTextSkip: false
	},
	Preset.ChooseCharacter: {
		Property.PositionX: 255,
		Property.PositionY: 590,
		Property.CenterAlign: true,
		Property.TalkAudio: UID.TALK_WMT,
		Property.PitchRange: 0.2,
		Property.Speed: 0.05,
		Property.OverlapAudio: true
	},
	Preset.RegularDialog: {
		Property.TalkAudio: UID.TALK_DEFAULT,
		Property.PitchRange: 0.15,
		Property.FontSize: 44,
		Property.Textbox: true,
		Property.PositionX: 150,
		Property.PositionY: 405,
		Property.LineLength: 850
	}
}

const character_dialog_text_offset = 150

func preset_variations():
	add_variation(Preset.OverworldTreeTalk, Preset.ChooseCharacter, {
		Property.PositionY: 525
	})
	add_variation(Preset.LegendBigPanel, Preset.LegendSmallPanel, {
		Property.PositionY: 540
	})
	add_variation(Preset.GameOver, Preset.ChooseCharacter, {
		Property.VectorPosition: Vector2(150, 350),
		Property.Outline: true,
		Property.InitialColor: Color.WEB_GRAY,
		Property.FontSize: 54,
		Property.LineLength: 850
	})
	add_variation(Preset.FirstGameOver, Preset.GameOver, {
		Property.LineLength: 0
	})
	add_variation(Preset.TreeTextCutoff, Preset.OverworldTreeTalk, {
		Property.EndExternally: true
	})
	add_variation(Preset.CharacterDialog, Preset.RegularDialog, {
		Property.PositionX: get_preset_property(Preset.RegularDialog, Property.PositionX) + character_dialog_text_offset,
		Property.LineLength: get_preset_property(Preset.RegularDialog, Property.LineLength) - character_dialog_text_offset
	})

func _ready():
	typewritterTimer.timeout.connect(print_next_char)
	want_next_text.connect(on_wanting_new_text)
	text_finished.connect(on_finished_text)
	preset_variations()

func add_variation(stored_as: Preset, from: Preset, deltas: Dictionary):
	if stored_as in TextConfigurations:
		push_error("Preset already in the configurations dictionary!")
		return
	if not from in TextConfigurations:
		push_error("There is not a preset currently loaded to variate!")
		return
	var preset_dict = TextConfigurations[from].duplicate(true) # prevents it from storing a reference
	for property in deltas.keys():
		var value = deltas[property]
		preset_dict[property] = value
	TextConfigurations[stored_as] = preset_dict

func get_preset_name(preset_member: Preset):
	return Preset.find_key(preset_member)

func on_finished_text():
	if textboxNode.visible:
		waitLeaf.show()

func color_to_hex(color: Color):
	return color.to_html(false).to_upper()

func print_text(text, speed, textSize, textPosition, lineLength, centerAlign, allowTextSkip, talkAudio, pitchRange, textbox, overlappingSounds, outline, initial_color, end_automatically, end_externally):
	Player.node.animationNode.stop()
	lockAction = true
	if overwriteSkippable:
		allowTextSkip = false
	delayed = false
	textFinished = false
	fontSize = textSize
	textNode.modulate.a = 1
	if outline: textNode = true_outlined_text
	else: textNode = true_text_node
	
	end_latest_text_automatically = end_automatically
	end_latest_text_externally = end_externally
	init_color = initial_color
	currentColor = color_to_hex(initial_color)
	textNode.scale = Vector2(fontSize, fontSize) / 48
	textNode.position = textPosition
	textNode.text = ""
	originalSpeed = speed
	currentTextAudio = talkAudio
	currentPitchRange = pitchRange
	textboxNode.visible = textbox
	currentOverlappingSoundsValue = overlappingSounds
	
	var regularText = record_control_text(text)
	printedText = split_text_by_lines(regularText, lineLength)
	textCanBeSkipped = allowTextSkip
	if centerAlign:
		align_to_center(regularText)
	
	currentCharacterIndex = 0
	if speed > 0 and regularText != "":
		typewritterTimer.start(speed)
		return
	
	textNode.text = printedText
	textFinished = true
	emit_signal("text_finished")

func print_preset(text, preset: Preset = Preset.Fallback):
	if preset == Preset.Fallback:
		preset = fallbackPreset
	
	print_text(
		text,
		get_preset_property(preset, Property.Speed),
		get_preset_property(preset, Property.FontSize),
		get_preset_property(preset, Property.VectorPosition),
		get_preset_property(preset, Property.LineLength),
		get_preset_property(preset, Property.CenterAlign),
		get_preset_property(preset, Property.AllowTextSkip),
		get_preset_property(preset, Property.TalkAudio),
		get_preset_property(preset, Property.PitchRange),
		get_preset_property(preset, Property.Textbox),
		get_preset_property(preset, Property.OverlapAudio),
		get_preset_property(preset, Property.Outline),
		get_preset_property(preset, Property.InitialColor),
		get_preset_property(preset, Property.EndAutomatically),
		get_preset_property(preset, Property.EndExternally)
	)

func get_preset_property(preset: Preset, property: Property):
	if not preset in TextConfigurations:
		var preset_name = get_preset_name(preset)
		push_error("Given preset '" + preset_name + "' was not properly configured!")
		return
	var preset_data = TextConfigurations[preset]
	
	match property:
		Property.Speed: return preset_data.get(Property.Speed, 1.0/30)
		Property.FontSize: return preset_data.get(Property.FontSize, 48)
		Property.VectorPosition: return get_text_position(preset)
		Property.PositionX: return preset_data.get(Property.PositionX, 0)
		Property.PositionY: return preset_data.get(Property.PositionY, 0)
		Property.LineLength: return preset_data.get(Property.LineLength, 0)
		Property.CenterAlign: return preset_data.get(Property.CenterAlign, false)
		Property.AllowTextSkip: return preset_data.get(Property.AllowTextSkip, true)
		Property.TalkAudio: return preset_data.get(Property.TalkAudio, null)
		Property.PitchRange: return preset_data.get(Property.PitchRange, 0)
		Property.Textbox: return preset_data.get(Property.Textbox, false)
		Property.OverlapAudio: return preset_data.get(Property.OverlapAudio, false)
		Property.Outline: return preset_data.get(Property.Outline, false)
		Property.InitialColor: return preset_data.get(Property.InitialColor, "#FFFFFF")
		Property.EndAutomatically: return preset_data.get(Property.EndAutomatically, false)
		Property.EndExternally: return preset_data.get(Property.EndExternally, false)

func get_text_position(preset: Preset):
	return Vector2(get_preset_property(preset, Property.PositionX), get_preset_property(preset, Property.PositionY))

func print_next_char():
	if delayed: return
	var delay = characterDelays.get(currentCharacterIndex, 0)
	currentColor = characterColors.get(currentCharacterIndex, currentColor)
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
	textFinished = true
	emit_signal("text_finished")
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

func clear_text(continue_text = false):
	textNode.text = ""
	typewritterTimer.stop()
	lockAction = false
	inChoicer = false
	textboxNode.hide()
	choicerNode.hide()
	if previousChoiceDirection in choiceNodes:
		choiceNodes[previousChoiceDirection].modulate = Color.WHITE
	leafNode.modulate.a = 1
	waitLeaf.hide()
	if continue_text: emit_signal("want_next_text")
	
func get_text_width(text) -> float:
	var font = textNode.get_theme_font("normal_font")
	return (font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fontSize)).x

func align_to_center(text):
	var centerX = standardScreenWidth / 2.0
	textNode.position.x = centerX - get_text_width(text) / 2

func fade_text(duration):
	var tween = create_tween()
	tween.tween_property(textNode, "modulate:a", 0, duration)
	await tween.finished
	clear_text()

var in_brackets : bool
var bracket_content : String
var parsed_ch_index : int
var resulting_text : String
const control_brackets := ["{", "}"]

func record_control_text(text: String) -> String:
	if not text.contains("{") and not text.contains("}"): return text
	setup_control_text_parsing()
	for i in range(text.length()):
		var letter = text[i]
		if letter in control_brackets and Localization.is_previous_character("\\", i, text):
			parse_regular_character(letter, i, text)
			continue
		match letter:
			"{":
				bracket_content = ""
				in_brackets = true
			"}":
				if not in_brackets: continue
				parse_control_bracket_end()
			_:
				parse_regular_character(letter, i, text)
	
	return resulting_text

func parse_regular_character(letter, index, text):
	if letter == "\\" and get_next_character(index, text) in control_brackets: return
	bracket_content += letter
	if in_brackets: return
	parsed_ch_index += 1
	resulting_text += letter

func get_next_character(index, text):
	var next_index = index + 1
	if next_index >= text.length(): return null
	var next_character = text[next_index]
	return next_character

func setup_control_text_parsing():
	characterDelays.clear()
	characterColors.clear()
	in_brackets = false
	bracket_content = ""
	parsed_ch_index = 0
	resulting_text = ""

func parse_control_bracket_end():
	in_brackets = false
	
	if bracket_content.is_valid_float():
		characterDelays.set(parsed_ch_index, float(bracket_content))
		return
	
	if bracket_content.begins_with("#"):
		if Color.html_is_valid(bracket_content): set_character_color(bracket_content)
		else: set_character_color(substitute_for_named_color(bracket_content))
		return
	
	var placeholder_variable = "{" + bracket_content + "}"
	resulting_text += placeholder_variable
	parsed_ch_index += placeholder_variable.length()

func set_character_color(character_color):
	if character_color == null: return
	characterColors.set(parsed_ch_index, character_color)

func substitute_for_named_color(named_color: String):
	var color_name = named_color.substr(1).to_lower()
	if color_name == "/" or color_name == "": return init_color
	
	var used_color = Color.from_string(color_name, invalid_color)
	if used_color != invalid_color: return color_to_hex(used_color)
	
	match color_name:
		"holy_yellow": Color("ebc934")
		"blue_fire": Color("3498eb")
		"tree_green": Color("5fad28")
		"glow_mushroom": Color("00c9ca")

	push_error("Attempted to use unknown color '" + color_name + "'!")
	return null

const invalid_color = Color(0.123, 0.456, 0.789) # placeholder color used in case, where Color.from_string fails

func skip_text():
	if not textCanBeSkipped: return
	textNode.text = add_color_to_text(printedText)
	currentCharacterIndex = printedText.length()

func add_color_to_text(text) -> String:
	var resultText = ""
	var addFuncCurrentColor = init_color
	if init_color is String:
		addFuncCurrentColor = color_to_hex(init_color)
	for i in range(text.length()):
		var ch = text[i]
		addFuncCurrentColor = characterColors.get(i, addFuncCurrentColor)
		resultText += "[color=" + addFuncCurrentColor + "]" + ch + "[/color]"
	return resultText

func _unhandled_input(_event: InputEvent):
	if end_latest_text_externally: return
	if (Input.is_action_just_pressed("continue") or Input.is_action_pressed("skip_text")) and textFinished:
		emit_signal("want_next_text")
	if Input.is_action_just_pressed("continue") and inChoicer:
		on_choice_decided()
	if Input.is_action_just_pressed("move_fast") or Input.is_action_pressed("skip_text"):
		skip_text()
	if inChoicer:
		handle_choicer_inputs()

func print_localization(text_key, variables = [], preset: Preset = Preset.Fallback):
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

func give_choice(choiceAKey, choiceBKey, choiceCKey = "", choiceDKey = ""):
	waitLeaf.hide()
	previousChoiceDirection = Vector2.ZERO
	lockAction = true
	inChoicer = true
	textboxNode.show()
	choicerNode.show()
	leafNode.position = defaultLeafPosition
	
	var choiceAText = Localization.get_text(choiceAKey)
	var choiceBText = Localization.get_text(choiceBKey)
	var choiceCText = "" if choiceCKey == "" else Localization.get_text(choiceCKey)
	var choiceDText = "" if choiceDKey == "" else Localization.get_text(choiceDKey)
	
	choiceList = [choiceAKey, choiceBKey, choiceCKey, choiceDKey]
	choiceNodes[Vector2(-1, 0)].text = choiceAText
	choiceNodes[Vector2(+1, 0)].text = choiceBText
	choiceNodes[Vector2(0, -1)].text = choiceCText
	choiceNodes[Vector2(0, +1)].text = choiceDText
	await submitted_choice

func give_choice_wait(choiceAText, choiceBText, choiceCText = "", choiceDText = ""):
	give_choice(choiceAText, choiceBText, choiceCText, choiceDText)
	await submitted_choice

func print_wait(text, preset: Preset = Preset.Fallback):
	print_preset(text, preset)
	await want_next_text

func print_wait_localization(text, variables = [], preset: Preset = Preset.Fallback):
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
	Audio.play_sound(UID.SFX_MENU_CHANGED_CHOICE, 0.1)
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

func end_npc_dialog(npcID: NPCData.ID, npc, deleteAfterTalk := false):
	if deleteAfterTalk:
		NPCData.set_data(npcID, NPCData.Field.Deleted, true)
		npc.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	canInteract = true
	NPCData.set_data(NPCData.ID.InteractionPrompt_SPAWNROOM, NPCData.Field.Deactivated, true)

func optional_get_item(
		item: Inventory.Item,
		count := 1,
		npcNode: Node = null,
		npcID: NPCData.ID = NPCData.ID.Uninitialized,
		color: Color = Color.YELLOW):

	var itemJsonIdentifier = Inventory.get_item_name(item)
	var colorControlText = "{#" + color.to_html() + "}"
	var fullVariableString = colorControlText + itemJsonIdentifier + "{#/}"
	await print_wait_localization("item_choice_pickup", [fullVariableString])
	
	await give_basic_choice()
	if lastChoiceText == "choicer_decline":
		var textKey = "item_decline_" + Inventory.get_item_enum(item)
		if Localization.text_exists(textKey): await print_wait_localization(textKey)
		return
	
	var itemTier = Inventory.get_item_tier(item)
	var itemStringCount = ""
	if count > 1: itemStringCount = " (" + str(count) + "x)"
	await print_wait_localization("item_confirm_pickup_" + itemTier, [fullVariableString, itemStringCount])
	Inventory.add_item(item, count)
	Audio.play_sound(UID.SFX_ITEM_OBTAINED)
	
	if npcNode != null:
		npcNode.queue_free()
		NPCData.set_data(npcID, NPCData.Field.Deleted, true)
	after_obtainted_item(item)

func after_obtainted_item(item):
	match item:
		Inventory.Item.GLOWING_MUSHROOM:
			NPCData.set_data(NPCData.ID.BlockTree_SPAWNROOM, NPCData.Field.Suffix, "NoLight_")
			NPCData.set_data(NPCData.ID.BlockTree_SPAWNROOM, NPCData.Field.InteractionCount, 0)

func give_basic_choice():
	await give_choice_wait("choicer_agree", "choicer_decline")

func print_sequence(base_key, variables := {}, preset := Preset.Fallback, suffix := ""):
	var text_index = 1
	var used_key = add_suffix_to_key(base_key, suffix)
	while true:
		var current_text_key = used_key + str(text_index)
		text_index += 1
		var next_text_key = used_key + str(text_index)
		var next_text_invalid = not Localization.text_exists(next_text_key)
		print_localization(current_text_key, variables, preset)
		await text_finished
		if next_text_invalid: emit_signal("sequence_finished")
		await want_next_text
		if next_text_invalid: break

func add_suffix_to_key(base_key, suffix := ""):
	var used_key = base_key + "_"
	if suffix != "": used_key += suffix + "_"
	return used_key

func print_random_sequence(base_key, suffix := "", variables := {}, preset := Preset.Fallback):
	var used_key = add_suffix_to_key(base_key, suffix)
	var attempt_count = 0
	var sequence_key = ""
	while true:
		if attempt_count >= 10000: return false
		var random_num = randi_range(1, max_random_sequences)
		sequence_key = used_key + str(random_num)
		var validation_key = sequence_key + "_1"
		if Localization.text_exists(validation_key): break
		attempt_count += 1
	await print_sequence(sequence_key, variables, preset)
	return true
