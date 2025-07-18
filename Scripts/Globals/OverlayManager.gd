extends Control

@onready var fadeOverlay = $CanvasLayer/Overlay

var activeTween: Tween
var sceneChangingDisabled = false
signal finished

func _ready():
	fadeOverlay.color.a = 0

func set_alpha(a):
	fadeOverlay.color.a = a

func hide_overlay():
	fadeOverlay.color.a = 1

func show_overlay():
	fadeOverlay.color.a = 0

func show_scene(duration = 1.0):
	overlay_tween(Color(fadeOverlay.color, 0), duration)
	await finished

func hide_scene(duration = 1.0):
	overlay_tween(Color(fadeOverlay.color, 1), duration)
	await finished

func overlay_tween(color: Color, duration = 1):
	kill_tween()
	activeTween = create_tween()
	activeTween.tween_property($CanvasLayer/Overlay, "color", color, duration)
	await activeTween.finished
	emit_signal("finished")

func kill_tween():
	if activeTween != null and is_instance_valid(activeTween):
		activeTween.kill()

func change_scene(scene, hideDuration = 1, showDuration = 1, betweenSceneWait: float = 0):
	if sceneChangingDisabled: return
	sceneChangingDisabled = true
	hide_scene(hideDuration)
	await finished
	if betweenSceneWait > 0:
		await get_tree().create_timer(betweenSceneWait).timeout
	TextSystem.clear_text()
	if SaveData.allow_game_load:
		load_post_legend_scene()
	else:
		get_tree().change_scene_to_file(scene)
	show_scene(showDuration)
	await finished
	sceneChangingDisabled = false

func load_post_legend_scene():
	var nextScenePath = "res://Scenes/ChooseCharacter.tscn"
	if CutsceneManager.is_cutscene_finished(CutsceneManager.Cutscene.ChoosePlayer):
		Overworld.enable()
		nextScenePath = "res://Scenes/Audio.tscn" # empty scene
	if Overworld.saveFileCorrupted: nextScenePath = "res://Rooms/ErrorHandler.tscn"
	get_tree().change_scene_to_file(nextScenePath)
