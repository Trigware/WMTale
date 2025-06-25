extends Node2D

const scaleConst := 1.7

var activeRoom = null
var currentRoom := Room.Weird_SpawnRoom
var initialPosition := Vector2(0, 0)
var latestExitRoom := Room.ErrorHandlerer
var saveFileCorrupted = false
@onready var music = $Music

func enable():
	scale = Vector2(scaleConst, scaleConst)
	Player.enable()
	load_room(currentRoom)

func load_room(room: Room):
	if activeRoom != null:
		activeRoom.queue_free()
	currentRoom = room
	var strRoom = get_room_enum(room)
	var roomPath = "res://Rooms/" + strRoom + ".tscn"
	if not ResourceLoader.exists(roomPath) or saveFileCorrupted:
		Player.disable()
		await get_tree().process_frame
		get_tree().change_scene_to_file("res://Rooms/ErrorHandler.tscn")
		return
	setup_loaded_room(roomPath, strRoom, room)

func setup_loaded_room(roomPath, strRoom, room: Room):
	var sceneRoom = load(roomPath)
	activeRoom = sceneRoom.instantiate()
	activeRoom.name = strRoom
	var roomEnterances = activeRoom.roomEnterances
	
	var newPlayerPosition = initialPosition
	if latestExitRoom in roomEnterances:
		var enteranceResource = roomEnterances[latestExitRoom]
		newPlayerPosition = get_enterance_effected_position(enteranceResource)
	
	var roomCutscene = activeRoom.cutscene
	if roomCutscene != CutsceneManager.Cutscene.None and not CutsceneManager.is_cutscene_finished(roomCutscene):
		newPlayerPosition = Vector2(activeRoom.cutscenePosition) * scaleConst
		CutsceneManager.let_cutscene_play_out(roomCutscene)
		
	latestExitRoom = room
	Player.set_pos(newPlayerPosition)
	await get_tree().process_frame
	add_child(activeRoom)
	var roomMusic = activeRoom.roomMusic
	Audio.play_music(roomMusic, activeRoom.roomMusicPitchRange, activeRoom.playNoMusic)

func get_enterance_effected_position(enteranceResource):
	var playerPos = Player.get_global_pos()
	var anchorPosition = enteranceResource.position
	var newPlayerPosition = Vector2.ZERO
	if enteranceResource.x_player_dependent:
		anchorPosition.y -= 32
		newPlayerPosition.x += playerPos.x
	if enteranceResource.y_player_dependent:
		anchorPosition.y -= 32
		newPlayerPosition.y += playerPos.y
	newPlayerPosition += anchorPosition * scaleConst
	return newPlayerPosition

enum Room
{
	ErrorHandlerer = -1,
	Weird_SpawnRoom,
	Weird_SpawnRoomEnterance,
	Weird_TeleportRoom,
	Weird_RiverBridge
}

func get_room_enum(room: Room) -> String:
	var roomName = Room.find_key(room)
	if roomName == null:
		return ""
	return roomName.replace("_", "/")
