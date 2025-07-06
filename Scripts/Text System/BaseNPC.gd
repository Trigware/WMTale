extends Area2D

@export var npcID := NPCData.ID.Uninitialized
@export var item := Inventory.Item.NONE
@export var itemCount := 1
@export var itemColor := Color.YELLOW
@export var removeStaticBody := false
@export var autoTrigger := false
@export var deleteAfterTalk := false
@export var ignoreDirections := false
@export var disable_placeholder_interactions := false
@export var deactivated_at_start := false

@onready var triggerZone = $"Trigger Zone"

var interactionCount := 0
var textID := ""
var placeholderInteraction : String
var placeholderExists : bool
var first_text : String
var first_text_exists : bool

var padestalTexts := [NPCData.ID.Pedestal_SPAWN_ENTERANCE]

func _ready():
	if npcID == NPCData.ID.Uninitialized:
		push_error("NPC ID is not initiliazed!")
		return
	await get_tree().process_frame
	if deactivated_at_start:
		NPCData.set_data(npcID, NPCData.Field.Deactivated, true)
	textID = NPCData.get_id_name(npcID)
	var isNPCDeleted = NPCData.get_data(npcID, NPCData.Field.Deleted)
	if isNPCDeleted: queue_free()
	if removeStaticBody and has_node("Static Body"):
		$"Static Body".queue_free()
	placeholderInteraction = textID + "_outofinteract"
	placeholderExists = Localization.text_exists(placeholderInteraction)
	first_text = get_current_text(1, true)
	first_text_exists = Localization.text_exists(first_text)
	if not placeholderExists and not first_text_exists:
		push_error("No text key with NPC ID exists (" + textID + ")!")

func _process(_delta):
	if (not Input.is_action_just_pressed("continue") and not autoTrigger) or not TextSystem.canInteract: return
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("Player"):
			interact_with_npc()
			return

func interact_with_npc():
	if NPCData.get_data(npcID, NPCData.Field.Deactivated) or TextSystem.lockAction: return
	if not is_player_looking_towards_npc(): return
	interactionCount = NPCData.get_incremented_data(npcID, NPCData.Field.InteractionCount)
	TextSystem.canInteract = false
	
	if not placeholderExists and not disable_placeholder_interactions: placeholderInteraction = "npc_outofinteract"
	
	if not first_text_exists:
		await TextSystem.print_wait_localization(placeholderInteraction)
	else: await print_regular_npc_text()
	
	if item != Inventory.Item.NONE:
		await TextSystem.optional_get_item(Inventory.Item.GLOWING_MUSHROOM, itemCount, self, npcID, itemColor)
	
	await after_base_dialog_complete()
	TextSystem.end_npc_dialog(npcID, self, deleteAfterTalk)

func print_regular_npc_text():
	var i = 1
	var currentText = get_current_text(1)
	while Localization.text_exists(currentText):
		await TextSystem.print_wait_localization(currentText)
		i += 1
		currentText = get_current_text(i)

func get_current_text(index, interact_override = false, interact_override_value = 1):
	var used_interaction_count = interactionCount
	if interact_override: used_interaction_count = interact_override_value
	var suffix = NPCData.get_data(npcID, NPCData.Field.Suffix)
	return textID + "_" + suffix + str(used_interaction_count) + "_" + str(index)

func is_player_looking_towards_npc() -> bool:
	if autoTrigger or removeStaticBody or ignoreDirections: return true
	var playerPos : Vector2 = Player.get_global_pos()
	var npcPos : Vector2 = triggerZone.global_position
	var playerDir = Player.node.animationDir
	
	match playerDir:
		Vector2.LEFT: return playerPos.x > npcPos.x
		Vector2.RIGHT: return playerPos.x < npcPos.x
		Vector2.UP: return playerPos.y > npcPos.y
		_: return playerPos.y < npcPos.y

func after_base_dialog_complete():
	if npcID in padestalTexts:
		await TextSystem.give_basic_choice()
		if TextSystem.lastChoiceText == Localization.get_text("choicer_decline"): return
		await TextSystem.print_wait_localization("PedestalText_intro", [SaveData.playerName])
		var textPrefix = "PedestalText_" + SaveData.selectedCharacter + "_"
		await TextSystem.print_sequence_no_variables(
			[textPrefix + "1",
			textPrefix + "2",
			"PedestalText_end"]
		)
