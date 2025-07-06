extends Node2D

@onready var subtractiveLight = $Light
@onready var health_root = $CanvasLayer/Health
@onready var health_bar = $"CanvasLayer/Health/Green Health Bar"
@onready var damage_bar = $"CanvasLayer/Health/Damage Bar"
@onready var playerHealth = $"CanvasLayer/Health/Player Health"
@onready var playerHead = $"CanvasLayer/Health/Player Head"
@onready var staminaCircle = $"CanvasLayer/Stamina/Stamina Circle"
@onready var staminaRect = $"CanvasLayer/Stamina/Stamina Rect"
@onready var staminaLabel = $"CanvasLayer/Stamina/Stamina Label"
@onready var staminaLeaf = $"CanvasLayer/Stamina/Stamina Leaf"
@onready var stamina_root = $"CanvasLayer/Stamina"
@onready var timer = $"Not Hit Timer"

const screen_shake_offset = 12
const screen_shake_duration = 0.15
const invincibility_duration = 0.35
const ui_tween_duration = 0.7

var cannot_start_hp_tween = false
var invincibility = false
var health_bar_tween
var damage_bar_tween

func enabled():
	return stamina_root.position.x > -300

func tween_light(final):
	var tween = create_tween()
	tween.tween_property(subtractiveLight, "energy", final, 1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func tween_ui(final):
	create_tween().tween_property(stamina_root, "position:x", final, ui_tween_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _ready():
	playerHead.texture = load("res://Textures/UI Heads/" + SaveData.selectedCharacter + "Head.png")
	timer.timeout.connect(hide_health_ui)
	restore_all_health()
	restore_all_stamina()

func update_health(updateTo):
	var used_update_to = max(0, updateTo)
	if used_update_to > Player.playerMaxHealth:
		restore_all_health()
		return
	Player.playerHealth = used_update_to
	health_bar.max_value = Player.playerMaxHealth
	health_bar.value = Player.playerHealth
	var labelText = Localization.get_text("character_max_stat")
	if Player.playerHealth != Player.playerMaxHealth: labelText = str(floori(Player.playerHealth))
	playerHealth.text = labelText
	if updateTo <= 0:
		trigger_game_over()

func change_health(by):
	update_health(Player.playerHealth + by)

func restore_all_health():
	update_health(Player.playerMaxHealth)

func update_stamina(update_to):
	if update_to > Player.maxStamina:
		restore_all_stamina()
		return
	Player.stamina = max(0, update_to)
	var circleMax = Player.maxStamina / 100.0 * 65
	staminaCircle.max_value = circleMax
	staminaRect.min_value = circleMax
	staminaRect.max_value = Player.maxStamina
	staminaCircle.value = update_to
	staminaRect.value = update_to
	var staminaText = Localization.get_text("character_max_stat")
	if Player.stamina != Player.maxStamina: staminaText = str(floori(Player.stamina / Player.maxStamina * 100)) + "%"
	staminaLabel.text = staminaText
	var leafAlpha = Player.stamina / Player.maxStamina
	staminaLeaf.modulate.a = leafAlpha
	Player.light.texture_scale = clamp(Player.stamina/Player.maxStamina + 0.5, 0.5, 1.5)

func trigger_game_over():
	pass

func restore_all_stamina():
	update_stamina(Player.maxStamina)

func change_stamina(by):
	update_stamina(Player.stamina + by)

func damage_player(by):
	if invincibility or not enabled(): return
	
	var original_health = Player.playerHealth
	damage_bar.max_value = Player.playerMaxHealth
	damage_bar.value = original_health
	
	change_health(-by)
	var health_delta = Player.playerHealth - original_health
	if health_delta == 0: return
	screen_shake_multiple(3)
	health_ui_tween(5, ui_tween_duration/2)
	damage_tween_func(by)
	
	spawn_health_change_info_particle(health_delta)
	timer.start()
	invincibility = true
	var previous_player_modulate = Player.node.modulate
	
	await create_tween().tween_property(Player.node, "modulate", Color.RED, invincibility_duration/2).finished
	await create_tween().tween_property(Player.node, "modulate", previous_player_modulate, invincibility_duration/2).finished
	invincibility = false

func screen_shake_multiple(count):
	for i in range(count):
		await screen_shake(float(count-i)/count)

func damage_using_id(id: DamageID):
	var health_change = 0
	match id:
		DamageID.SinkUnderwater: health_change = 25
		DamageID.RedMushroom: health_change = 15
	damage_player(health_change)

func screen_shake(power = 1):
	var original_camera_offset = Player.camera.offset
	var used_offset = screen_shake_offset * power
	var screen_shake_final = Vector2(original_camera_offset.x + used_offset, original_camera_offset.y + used_offset)
	var shake_tween = create_tween()
	await shake_tween.tween_property(Player.camera, "offset",\
		screen_shake_final, screen_shake_duration/2).\
		set_trans(Tween.TRANS_SINE).\
		set_ease(Tween.EASE_IN_OUT).finished
	await create_tween().tween_property(Player.camera, "offset", original_camera_offset, screen_shake_duration/2).finished
	await get_tree().create_timer(screen_shake_duration/2).timeout

func health_ui_tween(final, duration):
	if health_bar_tween != null: health_bar_tween.kill()
	elif cannot_start_hp_tween: return
	cannot_start_hp_tween = true
	var tween = create_tween()
	health_bar_tween = tween
	tween.tween_property(health_root, "position:x", final, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await health_bar_tween.finished
	cannot_start_hp_tween = false

func hide_health_ui():
	health_ui_tween(-425, ui_tween_duration)

func damage_tween_func(damage_taken):
	if damage_bar_tween != null: damage_bar_tween.kill()
	var tween = create_tween()
	damage_bar_tween = tween
	var tween_duration = max(damage_taken / Player.playerMaxHealth, 1.0) * 0.75
	tween.tween_property(damage_bar, "value", Player.playerHealth, tween_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)

func spawn_health_change_info_particle(health_change):
	var scene : PackedScene = load("res://Scenes/Health Change Info.tscn")
	var instance = scene.instantiate()
	
	Player.hp_particle_point.add_child(instance)
	instance.set_hp_delta(health_change)
	
func post_river_fail(marker):
	Overlay.hide_scene(1)
	await Overlay.finished
	
	Player.node.global_position = marker.global_position
	
	var walkable_lilypads_node = Overworld.activeRoom.get_node("Walkable Lilypads")
	walkable_lilypads_node.queue_free()
	var scene_name = "res://Scenes/" + Overworld.activeRoom.name + " Lilypads.tscn"
	await get_tree().process_frame
	var scene = load(scene_name).instantiate()
	scene.name = "Walkable Lilypads"
	Overworld.activeRoom.add_child(scene)
	
	Player.go_outside_water(true)
	Player.reset_camera_pos()
	Overlay.show_scene(1)
	TextSystem.lockAction = false
	LeafMode.restore_all_stamina()
	
	Player.node.stringAnimation = "Down"
	Player.node.update_walk_animation_frame()
	Player.tween_leaf_alpha(1)
	await get_tree().create_timer(0.05).timeout
	Player.is_sinking = false

enum DamageID {
	SinkUnderwater,
	RedMushroom
}
