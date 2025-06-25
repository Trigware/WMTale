extends Node

var game_text : Dictionary = {}

func _ready():
	load_language("czech")

func get_text(text_key, variables : Array = []) -> String:
	if not text_exists(text_key): return "REPORT ERROR " + text_key + " (" + SaveData.currentLanguage + ")"
	return insert_variables(game_text[text_key], variables)

func text_exists(text_key) -> bool:
	return text_key in game_text

func load_language(newLanguage):
	SaveData.currentLanguage = newLanguage
	var jsonFilePath = "res://Language Files/" + SaveData.currentLanguage + ".json"
	var file = FileAccess.open(jsonFilePath, FileAccess.READ)
	if not file: return
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
				
				if bracketContent.is_valid_float() or (bracketContent.length() > 0 and bracketContent[0] == "#"):
					modifiedText += '{' + bracketContent + '}'
					continue
				
				var variableContent = ""
				if bracketContent in insertedVarDict:
					variableContent = insertedVarDict[bracketContent]
				else:
					if insertedVarDict.size() >= variables.size(): push_error("Need a variable '" + bracketContent + "' that can be passed into the text! (index: " + str(insertedVarDict.size()) + ")")
					variableContent = variables[insertedVarDict.size()]
					insertedVarDict[bracketContent] = variableContent
				modifiedText += str(variableContent)
			_:
				if inBracket: bracketContent += ch
				else: modifiedText += ch
	return modifiedText
