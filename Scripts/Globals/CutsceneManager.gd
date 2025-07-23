extends Node

var FinishedCutscenes := []
var action_lock = false
var latest_cutscene_name = ""

enum Cutscene
{
	None,
	ChoosePlayer,
	SpawnRoom,
	Legend,
	CemetaryGate
}

signal cutscene_completed


func wait(duration):
	await get_tree().create_timer(duration).timeout

func get_enum_name(cutscene: Cutscene):
	return Cutscene.find_key(cutscene)

func add_finished_cutscene_flag(cutscene: Cutscene):
	FinishedCutscenes.append(get_enum_name(cutscene))

func is_cutscene_finished(cutscene: Cutscene):
	return get_enum_name(cutscene) in FinishedCutscenes

func let_cutscene_play_out(cutscene: Cutscene, defined_paths := {}):
	var cutscene_name = get_enum_name(cutscene)
	if cutscene_name in FinishedCutscenes: return
	latest_cutscene_name = get_enum_name(cutscene)
	var function_name = "play_" + latest_cutscene_name.to_lower() + "_cutscene"
	if not has_method(function_name):
		push_error("Attempted to play the " + latest_cutscene_name + " cutscene which doesn't have an associated function!")
		return
	action_lock = true
	call(function_name)
	await cutscene_completed
	after_cutscene_finished(cutscene)

func play_spawnroom_cutscene():
	Player.update_animation("LookDown")
	await wait(2)
	Player.update_animation("WalkRight")
	emit_signal("cutscene_completed")
	await Audio.play_sound(UID.SFX_GET_UP)
	Audio.play_music("Weird Forest", 0.1)

func after_cutscene_finished(cutscene: Cutscene):
	action_lock = false
	add_finished_cutscene_flag(cutscene)

func play_cemetarygate_cutscene():
	await Player.move_camera_to(465, -850)
	await wait(1)
	await TextSystem.print_sequence(get_base_cutscene_key(), {}, TextSystem.Preset.OverworldTreeTalk)
	await Player.return_camera()
	emit_signal("cutscene_completed")

func get_base_cutscene_key():
	var base_key = "Cutscene_" + CutsceneManager.latest_cutscene_name
	return base_key
