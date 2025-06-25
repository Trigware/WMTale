extends Node

var FinishedCutscenes := []

enum Cutscene
{
	None,
	ChoosePlayer,
	SpawnRoom
}

signal cutscene_completed

func get_enum_name(cutscene: Cutscene):
	return Cutscene.find_key(cutscene)

func add_finished_cutscene_flag(cutscene: Cutscene):
	FinishedCutscenes.append(get_enum_name(cutscene))

func is_cutscene_finished(cutscene: Cutscene):
	return get_enum_name(cutscene) in FinishedCutscenes

func let_cutscene_play_out(cutscene: Cutscene):
	var cutscene_name = get_enum_name(cutscene)
	var function_name = "play_" + cutscene_name.to_lower() + "_cutscene"
	if not has_method(function_name):
		push_error("Attempted to play the " + cutscene_name + " cutscene which doesn't have an associated function!")
		return
	TextSystem.lockAction = true
	call(function_name)
	await cutscene_completed
	after_cutscene_finished(cutscene)

func play_spawnroom_cutscene():
	Player.update_animation("LookDown")
	await get_tree().create_timer(2).timeout
	Player.update_animation("WalkRight")
	emit_signal("cutscene_completed")
	await Audio.play_sound("res://Audio/SFX/GetUp.mp3")
	Audio.play_music("Weird Forest", 0.1)

func after_cutscene_finished(cutscene: Cutscene):
	TextSystem.lockAction = false
	add_finished_cutscene_flag(cutscene)
