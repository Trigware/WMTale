extends Node

var game_text : Dictionary = {}
const localization_key_path = "res://WMTale - Localization.tsv"
var language_column_index = 0
var language_list := []

func get_text(text_key, variables = []) -> String:
	if not text_exists(text_key) and game_text == {}: load_language(SaveData.currentLanguage)
	if not text_exists(text_key): return text_key + " (" + SaveData.currentLanguage + ")"
	var localized_text = insert_variables(game_text[text_key], variables)
	if localized_text == "":
		localized_text = "w/o " + SaveData.currentLanguage + " " + text_key
	return localized_text

func get_key_suffixed(base_key, suffix) -> String:
	return base_key + "_" + str(suffix)

func text_exists(text_key) -> bool:
	return text_key in game_text

func load_language(newLanguage):
	SaveData.currentLanguage = newLanguage
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
			if not "AI" in language_list: push_error("Localization file read error at row " + str(i) + "!")
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
	if SaveData.currentLanguage in language_list:
		language_column_index = language_list.find(SaveData.currentLanguage) + 1
		return 0
	load_language("english")
	return 1

func insert_variables(originalText : String, variables) -> String:
	var modifiedText = ""
	var inBracket = false
	var bracketContent = ""
	var insertedVarDict: Dictionary = {}
	if variables is Dictionary:
		insertedVarDict = variables
	for i in originalText.length():
		var ch = originalText[i]
		match ch:
			"{":
				inBracket = true
				bracketContent = ""
			"}":
				inBracket = false
				
				if bracketContent.is_valid_float() or (bracketContent.length() > 0 and bracketContent[0] == "#"):
					modifiedText += '{' + bracketContent + '}'
					continue
				
				var variableContent = ""
				if bracketContent in insertedVarDict:
					variableContent = insertedVarDict[bracketContent]
				else:
					if insertedVarDict.size() >= variables.size():
						if SaveData.currentLanguage != "AI": push_error("Need a variable '" + bracketContent + "' that can be passed into the text! (index: " + str(insertedVarDict.size()) + ")")
						variableContent = "{" + bracketContent + "}"
					else:
						variableContent = variables[insertedVarDict.size()]
						insertedVarDict[bracketContent] = variableContent
				modifiedText += str(variableContent)
			_:
				if inBracket: bracketContent += ch
				else: modifiedText += ch
	return modifiedText
