extends Node

var game_text : Dictionary = {}
const localization_key_path = "res://WMTale - Localization.tsv"
var language_column_index = 0
var language_list := []
var current_language := "english"
const control_characters := ["#", "?"]

func get_text(text_key, variables = []) -> String:
	if not text_exists(text_key) and game_text == {}: load_language(current_language)
	if not text_exists(text_key): return text_key + " (" + current_language + ")"
	var localized_text = parse_control_text(game_text[text_key], variables, text_key)
	if localized_text == "":
		localized_text = "w/o " + current_language + " " + text_key
	return localized_text

func get_key_suffixed(base_key, suffix) -> String:
	return base_key + "_" + str(suffix)

func text_exists(text_key) -> bool:
	return text_key in game_text

func load_language(newLanguage):
	current_language = newLanguage
	var file = FileAccess.open(localization_key_path, FileAccess.READ)
	if not file:
		game_text = {}
		return
	var file_contents = file.get_as_text()
	parse_tsv_file(file_contents)

func parse_tsv_file(file_contents):
	game_text = {}
	language_list.clear()
	var lines = file_contents.replace("\r", "").split("\n")
	for i in range(lines.size()):
		var line = lines[i]
		var columns = line.split("\t")
		if i == 0:
			if parse_first_csv_line(columns) != 0: return
			continue
		var column_count = columns.size()
		if language_column_index >= column_count or column_count == 0:
			push_error("Localization file read error at row " + str(i) + "!")
			continue
		var text_key = columns[0]
		var text_contents = unespace_string(columns[language_column_index])
		game_text[text_key] = text_contents

func unespace_string(text):
	text = text.replace("\\n", "\n")
	text = text.replace("\\t", "\t")
	text = text.replace("\\\"", "\"")
	text = text.replace("\\\\", "\\")
	return text

func parse_first_csv_line(columns):
	for i in range(columns.size()):
		var column = columns[i]
		if i == 0: continue
		language_list.append(column)
	if current_language in language_list:
		language_column_index = language_list.find(current_language) + 1
		return 0
	load_language("english")
	return 1

var modified_text : String
var in_bracket : bool
var bracket_content : String
var inserted_variable_dict : Dictionary
var variable_count : int

func parse_control_text(original_text : String, variables, text_key) -> String:
	if not original_text.contains("{") and not original_text.contains("}"):
		return original_text
	parse_segment_setup(variables)
	
	for i in original_text.length():
		var ch = original_text[i]
		if ch in TextSystem.control_brackets and is_previous_character("\\", i, original_text):
			parse_default_character(ch)
			continue
		match ch:
			"{":
				in_bracket = true
				bracket_content = ""
			"}":
				parse_end_bracket_content(variables, text_key)
			_:
				parse_default_character(ch)
	
	if in_bracket:
		push_error("An openning bracket doesn't have an associated closing one!")
	return modified_text

func is_previous_character(ch, index, text):
	if index <= 0: return false
	var previous_character = text[index - 1]
	return previous_character == ch

func parse_default_character(ch):
	if in_bracket:
		bracket_content += ch
		return
	modified_text += ch

func parse_segment_setup(variables):
	modified_text = ""
	in_bracket = false
	bracket_content = ""
	inserted_variable_dict = {}
	variable_count = 0
	if variables is Dictionary:
		inserted_variable_dict = variables

func parse_end_bracket_content(variables, text_key):
	if not in_bracket:
		push_error("Found closing bracket which doesn't have an associated opening one!")
		return
	in_bracket = false
	var bracket_control_type = is_bracket_content_control_segment()
	if bracket_control_type != BracketControlOptions.Variable:
		if bracket_control_type == BracketControlOptions.Placeholder: add_placeholder_text()
		return
	
	if bracket_content in inserted_variable_dict:
		var dict_cache_var_content = inserted_variable_dict[bracket_content]
		modified_text += str(dict_cache_var_content)
		return
	
	var variable_index = inserted_variable_dict.size()
	
	var does_variable_exist = variable_index < variables.size()
	if not does_variable_exist:
		push_error("Need a variable '" + bracket_content + "' that can be passed into the text! (index: " + str(variable_count) + ", key: " + str(text_key) + ", lang: " + current_language + ")")
		add_placeholder_text()
		variable_count += 1
		return
	
	var variable_content = variables[variable_index]
	modified_text += str(variable_content)
	variable_count += 1

func add_placeholder_text(text = null):
	if text == null: text = bracket_content
	var placeholder_text = '{' + text + '}'
	modified_text += placeholder_text

func is_bracket_content_control_segment() -> BracketControlOptions:
	if bracket_content == "p":
		add_placeholder_text(str(TextSystem.default_pause_duration))
		return BracketControlOptions.Replaced
	
	if bracket_content.is_valid_float(): return BracketControlOptions.Placeholder
	if bracket_content.length() == 0: return BracketControlOptions.Placeholder
	
	var control_symbol = bracket_content[0]
	var is_control_segment = control_symbol in control_characters
	
	if is_control_segment: return BracketControlOptions.Placeholder
	return BracketControlOptions.Variable

enum BracketControlOptions {
	Variable,
	Placeholder,
	Replaced
}
