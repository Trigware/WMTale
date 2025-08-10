extends Node

const max_random_sequences = 50
const max_attempt_count = 1000

func clear_text(continue_text = false):
	TextSystem.textNode.text = ""
	TextSystem.typewritterTimer.stop()
	TextSystem.lockAction = false
	ChoicerSystem.in_choicer = false
	TextSystem.textboxNode.hide()
	TextSystem.choicerNode.hide()
	if ChoicerSystem.last_choicer_direction in TextSystem.choice_label_options:
		TextSystem.choice_label_options[ChoicerSystem.last_choicer_direction].modulate = Color.WHITE
	TextSystem.choicer_leaf.modulate.a = 1
	TextSystem.waitLeaf.hide()
	if continue_text: emit_signal("want_next_text")

func fade_text(duration):
	var tween = create_tween()
	tween.tween_property(TextSystem.textNode, "modulate:a", 0, duration)
	await tween.finished
	clear_text()

func print_localization(text_key, variables = [], preset := PresetSystem.Preset.Fallback):
	PresetSystem.print_preset(Localization.get_text(text_key, variables), preset)

func print_group(group: Array[String], variables = {}, preset := PresetSystem.Preset.Fallback):
	for text in group:
		print_localization(text, variables, preset)
		await TextSystem.want_next_text

func print_wait(text, preset := PresetSystem.Preset.Fallback):
	PresetSystem.print_preset(text, preset)
	await TextSystem.want_next_text

func print_wait_localization(text, variables = [], preset := PresetSystem.Preset.Fallback):
	print_localization(text, variables, preset)
	await TextSystem.want_next_text

var sequence_text_index : int
var sequence_base_key : String
var sequence_current_suffix : String

func print_sequence(base_key, variables := {}, preset := PresetSystem.Preset.Fallback, suffix := ""):
	sequence_text_index = 1
	sequence_base_key = base_key
	sequence_current_suffix = suffix
	var current_text_key = get_indexed_key(sequence_base_key, sequence_current_suffix, sequence_text_index)
	if not Localization.text_exists(current_text_key):
		await sequence_immediate_fail(sequence_base_key, sequence_current_suffix, variables, preset)
		return
	
	while true:
		var sequence_finished = await print_textkey_in_sequence(variables, preset)
		if sequence_finished: break

func print_textkey_in_sequence(variables, preset):
	var current_text_key = get_indexed_key(sequence_base_key, sequence_current_suffix, sequence_text_index)
	sequence_text_index += 1
	var next_text_key = get_indexed_key(sequence_base_key, sequence_current_suffix, sequence_text_index)
	var next_text_invalid = not Localization.text_exists(next_text_key)
	
	print_localization(current_text_key, variables, preset)
	await TextSystem.text_finished
	if TextSystem.current_line_choicer:
		sequence_current_suffix = ChoicerSystem.last_choicer_suffix
		sequence_text_index = 1
		next_text_invalid = not Localization.text_exists(get_indexed_key(sequence_base_key, sequence_current_suffix, sequence_text_index))
	
	await TextSystem.want_next_text
	if next_text_invalid: return true
	return false

func sequence_immediate_fail(base_key, suffix, variables, Preset):
	var indexless_key = add_suffix_to_key(base_key, suffix)
	await print_wait_localization(indexless_key, variables, Preset)

func add_suffix_to_key(base_key, suffix := ""):
	if suffix == "": return base_key
	return base_key + "_" + suffix

func get_indexed_key(base_key, suffix := "", index = 1):
	var suffixed_key = add_suffix_to_key(base_key, suffix)
	if index is String and index == "": return suffixed_key
	return suffixed_key + "_" + str(index)

func print_random_sequence(base_key, suffix := "", variables := {}, preset := PresetSystem.Preset.Fallback):
	var used_key = add_suffix_to_key(base_key, suffix)
	var attempt_count = 0
	var sequence_key = ""
	while true:
		if attempt_count >= max_attempt_count: return false
		var random_num = randi_range(1, max_random_sequences)
		sequence_key = used_key + "_" + str(random_num)
		var validation_key = sequence_key + "_1"
		if Localization.text_exists(validation_key): break
		attempt_count += 1
	await print_sequence(sequence_key, variables, preset)
	return true
