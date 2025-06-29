extends Node2D

const scaleConst := 1.7

var activeRoom = null
var currentRoom := Room.Weird_SpawnRoom
var latestExitRoom := Room.ErrorHandlerer
var initialPosition := Vector2.ZERO
var saveFileCorrupted = false
@onready var music = $Music
@onready var baseLight = $"Base Light"

func enable():
	scale = Vector2(scaleConst, scaleConst)
	Player.enable()
	load_room(currentRoom)
	baseLight.show()

func load_room(room: Room, newPlayerPosition := Vector2.ZERO):
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
	setup_loaded_room(roomPath, strRoom, room, newPlayerPosition)

func setup_loaded_room(roomPath, strRoom, room: Room, newPlayerPosition):
	var sceneRoom = load(roomPath)
	activeRoom = sceneRoom.instantiate()
	activeRoom.name = strRoom
	LeafMode.restore_all_stamina()
	
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

enum Room
{
	ErrorHandlerer = -1,
	Weird_SpawnRoom,
	Weird_SpawnRoomEnterance,
	Weird_TeleportRoom,
	Weird_RiverBridge,
	Weird_SquirrelMinigame
}

func get_room_enum(room: Room) -> String:
	var roomName = Room.find_key(room)
	if roomName == null:
		return ""
	return roomName.replace("_", "/")
