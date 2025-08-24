extends Node

const max_random_sequences = 50
const max_attempt_count = 1000
const suffix_seperator_character = "__"
const index_seperator_character = "#"

var latest_suffix_history := []

func clear_text(continue_text = false):
	TextSystem.true_outlined_text.text = ""
	TextSystem.textNode.text = ""
	TextSystem.typewritterTimer.stop()
	TextSystem.lockAction = false
	ChoicerSystem.in_choicer = false
	TextSystem.textboxNode.hide()
	TextSystem.choicerNode.hide()
	if ChoicerSystem.last_choicer_direction in TextSystem.choice_label_options:
		TextSystem.choice_label_options[ChoicerSystem.last_choicer_direction].modulate = Color.WHITE
	TextSystem.choicer_leaf.modulate.a = 1
	TextSystem.waitLeaf.modulate.a = 0
	if continue_text: TextSystem.emit_signal("want_next_text")

func fade_text(duration):
	var tween = create_tween()
	tween.tween_property(TextSystem.textNode, "modulate:a", 0, duration)
	await tween.finished
	clear_text()

func print_localization(text_key, variables = {}, preset := PresetSystem.Preset.Fallback):
	PresetSystem.print_preset(Localization.get_text(text_key, variables), preset)

func print_group(group: Array[String], variables = {}, preset := PresetSystem.Preset.Fallback):
	for text in group:
		await print_wait_localization(text, variables, preset)

func print_wait(text, preset := PresetSystem.Preset.Fallback):
	PresetSystem.print_preset(text, preset)
	await TextSystem.want_next_text

func print_wait_localization(text, variables = {}, preset := PresetSystem.Preset.Fallback):
	print_localization(text, variables, preset)
	await TextSystem.want_next_text

var sequence_text_index : int
var sequence_base_key : String
var sequence_current_suffix : String
var first_key_remove_index : bool
var next_text_invalid : bool

func print_sequence_setup(base_key, suffix):
	sequence_text_index = 1
	sequence_base_key = base_key
	sequence_current_suffix = suffix
	latest_suffix_history = []
	first_key_remove_index = false
	repair_key()

func print_sequence(base_key, variables := {}, preset := PresetSystem.Preset.Fallback, suffix := "root"):
	print_sequence_setup(base_key, suffix)
	while true:
		var sequence_finished = await print_textkey_in_sequence(variables, preset)
		if sequence_finished: break

func repair_key():
	if Localization.text_exists(get_sequence_key()): return
	
	if Localization.text_exists(get_indexed_key(sequence_base_key, sequence_current_suffix, "")):
		first_key_remove_index = true
	
	if sequence_current_suffix == "root" and Localization.text_exists(get_indexed_key(sequence_base_key, "", sequence_text_index)):
		sequence_current_suffix = ""

func get_sequence_key(override_index = null):
	var used_index = sequence_text_index
	if override_index != null: used_index = override_index
	return get_indexed_key(sequence_base_key, sequence_current_suffix, used_index)

func print_textkey_in_sequence(variables, preset):
	var used_sequence_index = sequence_text_index
	if first_key_remove_index: used_sequence_index =  ""
	var currently_printed_key = get_sequence_key(used_sequence_index)
	
	sequence_text_index += 1
	var next_text_key = get_sequence_key()
	next_text_invalid = not Localization.text_exists(next_text_key)
	print_localization(currently_printed_key, variables, preset)
	
	await TextSystem.text_finished
	first_key_remove_index = false
	
	var suffix_changed = TextSystem.current_line_choicer or TextParser.suffix_instruction_appeared != TextParser.SuffixType.None
	if suffix_changed: handle_suffix_change()
	
	await TextSystem.want_next_text
	if next_text_invalid: return true
	return false

func handle_suffix_change():
	sequence_current_suffix = ChoicerSystem.last_choicer_suffix if TextSystem.current_line_choicer else TextParser.latest_suffix_instruction
	if TextParser.suffix_instruction_appeared == TextParser.SuffixType.Random: handle_random_suffix()
	
	latest_suffix_history.append(sequence_current_suffix)
	sequence_text_index = 1
	
	var indexed_key = get_indexed_key(sequence_base_key, sequence_current_suffix, sequence_text_index)
	next_text_invalid = not Localization.text_exists(indexed_key)
	if Localization.text_exists(get_indexed_key(sequence_base_key, sequence_current_suffix, "")):
		next_text_invalid = false
		first_key_remove_index = true
	if next_text_invalid: push_error("Attempted to change to change to an invalid suffix '" + sequence_current_suffix + "'!")

func add_suffix_to_key(base_key, suffix := ""):
	if suffix == "": return base_key
	return base_key + suffix_seperator_character + suffix

func get_indexed_key(base_key, suffix := "", index = 1):
	var suffixed_key = add_suffix_to_key(base_key, suffix)
	if index is String and index == "": return suffixed_key
	return suffixed_key + index_seperator_character + str(index)

func handle_random_suffix():
	var biggest_key_variation = 1
	var simplified_key = add_suffix_to_key(sequence_base_key, sequence_current_suffix)
	while true:
		var key_with_random = simplified_key + str(biggest_key_variation)
		if not Localization.does_suffixed_key_exist(key_with_random): break
		biggest_key_variation += 1
	biggest_key_variation -= 1
	var chosen_variation = randi_range(1, biggest_key_variation)
	sequence_current_suffix += str(chosen_variation)
