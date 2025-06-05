extends Node

#region GameData
var selectedCharacter = "Rabbitek"
var playerName = ""
var choosePlayerSceneFinished = false
var currentLanguage = ""
#endregion

var allow_game_load = false
var save_path = "user://savefile1.json"
var resetSaveData = false # always set to false, once data is reset

func _ready():
	if resetSaveData:
		save_game()
	load_game()

func load_game():
	allow_game_load = false
	var loadedDictionary = load_dictionary()
	#region LoadData
	selectedCharacter = loadedDictionary["selectedCharacter"]
	playerName = loadedDictionary["playerName"]
	choosePlayerSceneFinished = loadedDictionary["choosePlayerSceneFinished"]
	currentLanguage = loadedDictionary["currentLanguage"]
	#endregion

func load_dictionary() -> Dictionary:
	if not FileAccess.file_exists(save_path):
		return {}

	var file := FileAccess.open(save_path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		var result : Variant = JSON.parse_string(content)
		if result is Dictionary:
			return result
		else:
			push_error("Failed to parse save file.")
			return {}
	return {}

func save_game():
	#region SaveData
	var saveData = {
		"selectedCharacter": selectedCharacter,
		"playerName": playerName,
		"choosePlayerSceneFinished": choosePlayerSceneFinished,
		"currentLanguage": currentLanguage
	}
	#endregion
	var file := FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		var json := JSON.stringify(saveData, '\t')
		file.store_string(json)
		file.close()
		if resetSaveData: print("Data Reset!")
