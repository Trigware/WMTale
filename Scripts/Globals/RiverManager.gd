extends Area2D

@export var shallow_water : Area2D
@export var river_fail_point : Marker2D

const river_fail_return_duration = 0.75
const shallow_water_sink = 0.15
const image_pixel_height = 36.0
var intended_leaf_pos = Player.leafNode.position
var is_sinking = false

func _process(_delta):
	for body in get_overlapping_bodies(): if body.is_in_group("Player"):
		sink_underwater()
		return
	for body in shallow_water.get_overlapping_bodies(): if body.is_in_group("Player"):
		on_entering_shallow_water()
		return
	go_outside_water()

func sink_underwater():
	if is_sinking: return
	is_sinking = true
	var leaf_tween = create_tween().tween_property(Player.leafNode, "modulate:a", 0, 0.7).set_ease(Tween.EASE_IN_OUT)
	TextSystem.lockAction = true
	Audio.play_sound("res://Audio/SFX/Deep Water Splash.mp3", 0.2, 5)
	
	player_river_damage()
	await sink_tween(1, 1.5)
	post_river_fail()

func player_river_damage():
	await get_tree().create_timer(1).timeout
	LeafMode.damage_player(20)

func post_river_fail():
	Overlay.hide_scene(1)
	await Overlay.finished
	
	Player.node.global_position = river_fail_point.global_position
	Player.reset_camera_pos()
	Overlay.show_scene(1)
	TextSystem.lockAction = false
	
	Player.node.stringAnimation = "Down"
	Player.node.update_walk_animation_frame()
	Player.tween_leaf_alpha(1)
	await get_tree().create_timer(0.05).timeout
	is_sinking = false

func sink_tween(final, duration):
	var sink_tween = create_tween()
	sink_tween.tween_method(
		func(val):
			Player.set_uniform("sink_progression", val+.001),
		Player.get_uniform("sink_progression"),
		final,
		duration
	).set_ease(Tween.EASE_IN_OUT)
	await sink_tween.finished

func on_entering_shallow_water():
	if Player.in_water: return
	Player.in_water = true
	Player.set_uniform("sink_progression", shallow_water_sink)
	Player.leafNode.position.y += shallow_water_sink * image_pixel_height
	Audio.play_sound("res://Audio/SFX/Splash.mp3", 0.2, 5)

func go_outside_water():
	if not Player.in_water: return
	Player.leafNode.position = intended_leaf_pos
	Player.in_water = false
	Player.set_uniform("sink_progression", 0)
