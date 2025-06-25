extends Node

#region GameData
var selectedCharacter = "xdaforge"
var playerName = ""
var currentLanguage = ""
var PlayerInventory := {}
#endregion

var allow_game_load = false
var resetPlayerData = false
var save_path = "user://savefile1.json"

func _ready():
	if resetPlayerData: reset_data()
	load_game()

func reset_data():
	write_to_savedata({})

func load_game():
	allow_game_load = false
	var loadedDictionary = load_dictionary()
	var positionDictionary: Dictionary[String, float] = {"X": 0.0, "Y": 0.0}
	#region LoadData
	selectedCharacter = loadedDictionary.get("selectedCharacter", selectedCharacter)
	playerName = loadedDictionary.get("playerName", playerName)
	currentLanguage = loadedDictionary.get("currentLanguage", currentLanguage)
	PlayerInventory = loadedDictionary.get("playerInventory", PlayerInventory)
	Overworld.currentRoom = loadedDictionary.get("currentRoom", Overworld.currentRoom)
	NPCData.data = loadedDictionary.get("NPCData", NPCData.data)
	positionDictionary["X"] = loadedDictionary.get("playerPosition", positionDictionary)["X"]
	positionDictionary["Y"] = loadedDictionary.get("playerPosition", positionDictionary)["Y"]
	CutsceneManager.FinishedCutscenes = loadedDictionary.get("FinishedCutscenes", CutsceneManager.FinishedCutscenes)
	#endregion
	Overworld.initialPosition = Vector2(positionDictionary["X"], positionDictionary["Y"])

func load_dictionary() -> Dictionary:
	if not FileAccess.file_exists(save_path):
		return {}

	var file := FileAccess.open(save_path, FileAccess.READ)
	if file != null:
		var content = file.get_as_text()
		file.close()
		return parse_json(content)
	
	Overworld.saveFileCorrupted = true
	return {}

func save_game():
	await get_tree().process_frame
	var playerPosition := {
		"X": Player.node.global_position.x,
		"Y": Player.node.global_position.y
	}
	#region SaveData
	var saveData = {
		"selectedCharacter": selectedCharacter,
		"playerName": playerName,
		"currentLanguage": currentLanguage,
		"playerInventory": PlayerInventory,
		"currentRoom": Overworld.currentRoom,
		"NPCData": NPCData.data,
		"playerPosition": playerPosition,
		"FinishedCutscenes": CutsceneManager.FinishedCutscenes
	}
	#endregion
	write_to_savedata(saveData)

func write_to_savedata(writtenData):
	var file := FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		var json := JSON.stringify(writtenData, '\t')
		file.store_string(json)
		file.close()

func parse_json(contents):
	var json = JSON.new()
	var error = json.parse(contents)
	if error != OK:
		Overworld.saveFileCorrupted = true
		return {}
	var result = JSON.parse_string(contents)
	return result
