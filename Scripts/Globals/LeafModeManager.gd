extends Node

@onready var subtractiveLight = $Light
@onready var playerUI = $CanvasLayer/Player
@onready var playerBar = $"CanvasLayer/Player/Player Bar"
@onready var playerHealth = $"CanvasLayer/Player/Player Health"
@onready var playerHead = $"CanvasLayer/Player/Player Head"
@onready var staminaCircle = $"CanvasLayer/Player/Stamina/Stamina Circle"
@onready var staminaRect = $"CanvasLayer/Player/Stamina/Stamina Rect"
@onready var staminaLabel = $"CanvasLayer/Player/Stamina/Stamina Label"
@onready var staminaLeaf = $"CanvasLayer/Player/Stamina/Stamina Leaf"

func enabled():
	return playerUI.position.x > -400

func tween_light(final):
	var tween = create_tween()
	tween.tween_property(subtractiveLight, "energy", final, 1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func tween_ui(final):
	create_tween().tween_property(playerUI, "position:x", final, 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _ready():
	playerHead.texture = load("res://Textures/UI Heads/" + SaveData.selectedCharacter + "Head.png")
	restore_all_health()
	restore_all_stamina()

func update_health(updateTo):
	if updateTo > Player.playerMaxHealth:
		restore_all_health()
		return
	Player.playerHealth = updateTo
	playerBar.max_value = Player.playerMaxHealth
	playerBar.value = Player.playerHealth
	var labelText = Localization.get_text("character_max_stat")
	if Player.playerHealth != Player.playerMaxHealth: labelText = str(floori(Player.playerHealth))
	playerHealth.text = labelText

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

func restore_all_stamina():
	update_stamina(Player.maxStamina)

func change_stamina(by):
	update_stamina(Player.stamina + by)
