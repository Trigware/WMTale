extends Node

var FinishedCutscenes := []
var action_lock = false
var latest_cutscene_name = ""
var cutscene_nodes : Dictionary = {}

enum Cutscene
{
	None,
	ChoosePlayer,
	SpawnRoom,
	Legend,
	CemetaryGate,
	Nixie_Introductory
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

func after_cutscene_finished(cutscene: Cutscene):
	action_lock = false
	add_finished_cutscene_flag(cutscene)

func get_base_cutscene_key():
	var base_key = "Cutscene_" + CutsceneManager.latest_cutscene_name
	return base_key

func let_cutscene_play_out(cutscene: Cutscene, cutscene_nodes_override := {}):
	if is_cutscene_finished(cutscene): return
	latest_cutscene_name = get_enum_name(cutscene)
	var function_name = "play_" + latest_cutscene_name.to_lower() + "_cutscene"
	if not has_method(function_name):
		push_error("Attempted to play the " + latest_cutscene_name + " cutscene which doesn't have an associated function!")
		return
	action_lock = true
	cutscene_nodes = cutscene_nodes_override
	call(function_name)
	await cutscene_completed
	after_cutscene_finished(cutscene)

func play_spawnroom_cutscene():
	Player.update_animation("spawn")
	await wait(2)
	Player.update_animation("walk_right")
	emit_signal("cutscene_completed")
	await Audio.play_sound(UID.SFX_GET_UP)
	Audio.play_music("Weird Forest", 0.1)

func play_cemetarygate_cutscene():
	await Player.move_camera_to(465, -850)
	await wait(1)
	await TextSystem.print_sequence(get_base_cutscene_key(), {}, TextSystem.Preset.OverworldTreeTalk)
	await Player.return_camera()
	emit_signal("cutscene_completed")

func play_nixie_introductory_cutscene():
	var nixie = cutscene_nodes["nixie"]
	nixie_logic_introductory(nixie)
	await wait(0.5)
	await TextSystem.print_wait_localization("Cutscene_Nixie_Introductory_TreeSaveDialog", {}, TextSystem.Preset.TreeTextCutoff)
	emit_signal("cutscene_completed")

func nixie_logic_introductory(nixie):
	nixie.scale_both_axis(1.15)
	nixie.set_uniform("moving_speed", 0.3)
	nixie.hide()
	nixie.set_anim("walk_left")
	nixie.set_uniform("hide_progression", 1)
	await wait(0.3)
	nixie.show()
	nixie.tween_hide_progression(0, 0.75)
	await wait(1)
	nixie.jump_to_point(Player.get_body_pos())
