extends Node2D

const scaleConst := 1.7

var activeRoom = null
var currentRoom := Room.Weird_SpawnRoom
var latestExitRoom := Room.ErrorHandlerer
var initialPosition := Vector2.ZERO
var saveFileCorrupted = false
var time_since_room_loaded = 0.0

@onready var music = $Music
@onready var baseLight = $"Base Light"

var base_light_color = Color("d9d9d9")

func _process(delta):
	time_since_room_loaded += delta

func enable():
	scale = Vector2(scaleConst, scaleConst)
	Player.enable()
	load_room(currentRoom, initialPosition * scaleConst)
	baseLight.show()
	baseLight.color = base_light_color

func disable():
	Player.disable()
	baseLight.hide()
	if activeRoom != null:
		activeRoom.queue_free()

func load_room(room: Room, newPlayerPosition := Vector2.ZERO):
	SaveData.save_autosave_file()
	if activeRoom != null:
		activeRoom.queue_free()
		await activeRoom.tree_exited
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
	Player.reset_camera_smoothing()
	await check_if_no_rooms_loaded()
	add_child(activeRoom)
	time_since_room_loaded = 0.0
	var roomMusic = activeRoom.roomMusic
	Audio.play_music(roomMusic, activeRoom.roomMusicPitchRange, activeRoom.playNoMusic)

func check_if_no_rooms_loaded():
	for child in get_children():
		var script = child.get_script()
		var is_room = script != null and script.resource_path.ends_with("BaseRoom.gd")
		if is_room:
			child.queue_free()
			await child.tree_exited

enum Room
{
	ErrorHandlerer = -1,
	Weird_SpawnRoom,
	Weird_SpawnRoomEnterance,
	Weird_TeleportRoom,
	Weird_LilypadRoom,
	Weird_CemetaryGate,
	Weird_SaveIntroRoom
}

func get_room_enum(room: Room) -> String:
	var roomName = Room.find_key(room)
	if roomName == null:
		return ""
	return roomName.replace("_", "/")
