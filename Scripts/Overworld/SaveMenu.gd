extends CanvasLayer

@onready var current_file = $"Current File"

var menu_openned = false
var saved_game = false

const change_visibility_duration = 0.5

func _ready():
	current_file.modulate.a = 0

func on_menu_open():
	if menu_openned: return
	NPCData.set_data(NPCData.ID.BibleInteractPrompt_SAVEINTROROOM, NPCData.Field.Deactivated, true)
	current_file.labels.modulate = Color.WHITE
	menu_openned = true
	TextSystem.lockAction = true
	saved_game = false
	Player.move_camera_by(175, 0, change_visibility_duration)
	Overlay.alpha_tween(0.25, change_visibility_duration)
	current_file_tween(1)
	current_file.set_player_name(SaveData.playerName)
	var get_previously_saved_room = SaveData.access_loaded_file_data("currentRoom")
	current_file.set_current_room(Overworld.get_room_ingame_name(get_previously_saved_room))
	var playTime = SaveData.access_loaded_autosave_data("PlayTime")
	current_file.set_playtime(convert_to_time_format(playTime, true))
	Player.end_leaf_flashes()
	await TextSystem.give_choice("OverworldSaving_SaveGame", "OverworldSaving_DontSave")
	after_choice_behavior()
	on_menu_close()

func current_file_tween(final):
	create_tween().tween_property(current_file, "modulate:a", final, change_visibility_duration)

func after_choice_behavior():
	if TextSystem.lastChoiceText == "OverworldSaving_DontSave": return
	SaveData.save_game()
	Audio.play_sound(UID.SFX_GAME_SAVED, 0.2)
	current_file.labels.modulate = Color.YELLOW
	saved_game = true
	current_file.set_current_room(Overworld.get_room_ingame_name(Overworld.currentRoom))
	current_file.set_playtime(convert_to_time_format(SaveData.PlayTime))

func on_menu_close():
	Player.return_camera(change_visibility_duration)
	current_file_tween(0)
	await Overlay.alpha_tween(0, change_visibility_duration)
	menu_openned = false

func convert_to_time_format(seconds, ignore_empty = false):
	if str(seconds) == "":
		return "0:00" if ignore_empty else ""
	var sec = str(int(seconds) % 60)
	if sec.length() == 1: sec = "0" + sec
	var minutes = str((int(seconds) / 60) % 60) + ":"
	var hours = str(int(seconds) / 3600) + ":"
	if hours == "0:": hours = ""
	elif minutes.length() == 2: minutes = "0" + minutes[0] + ":"
	return hours + minutes + sec
