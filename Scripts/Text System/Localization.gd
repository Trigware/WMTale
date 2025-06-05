extends Node

var game_text : Dictionary = {}

func get_text(text_key, variables : Array = []) -> String:
	if game_text.is_empty():
		load_language("czech")
	return insert_variables(game_text[text_key], variables)

func load_language(newLanguage):
	SaveData.currentLanguage = newLanguage
	var jsonFilePath = "res://Language Files/" + SaveData.currentLanguage + ".json"
	var file = FileAccess.open(jsonFilePath, FileAccess.READ)
	if not file:
		push_error("Failed to load the " + newLanguage + "localization file!")
		return
	game_text = JSON.parse_string(file.get_as_text())

func insert_variables(originalText : String, variables : Array) -> String:
	var modifiedText = ""
	var inBracket = false
	var bracketContent = ""
	var insertedVarDict: Dictionary = {}
	for i in originalText.length():
		var ch = originalText[i]
		match ch:
			"{":
				inBracket = true
				bracketContent = ""
			"}":
				inBracket = false
				if bracketContent.is_valid_float():
					modifiedText += '{' + bracketContent + '}'
				else:
					var variableContent = ""
					if bracketContent in insertedVarDict:
						variableContent = insertedVarDict[bracketContent]
					else:
						if insertedVarDict.size() >= variables.size(): push_error("Need a variable '" + bracketContent + "' that can be passed into the text!")
						variableContent = variables[insertedVarDict.size()]
						insertedVarDict[bracketContent] = variableContent
					modifiedText += variableContent
			_:
				if inBracket: bracketContent += ch
				else: modifiedText += ch
	return modifiedText
