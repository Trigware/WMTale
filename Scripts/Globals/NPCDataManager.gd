extends Node

enum ID
{
	Uninitialized,
	Mushroom_SPAWNROOM,
	PurpleTree_SPAWNROOM,
	BlockTree_SPAWNROOM,
	InteractionPrompt_SPAWNROOM,
	SpawnObject_SPAWNROOM,
	Pedestal_SPAWN_ENTERANCE,
	Leaves_SPAWN_ENTERANCE,
	TeleportTree_SPAWN_TELEPORT,
	BrokenSign_SPAWN_ENTERANCE,
	FallenTree_LILYPADROOM,
	SmallBranch_LILYPADROOM,
	LilypadFlower_LILYPADROOM,
	StreetLamp_WEIRDFOREST,
	BlueCampfire_SPAWN_TELEPORT,
	BigBranch_LILYPADROOM,
	CemetaryGate_GATEROOM,
	Candle_SAVEINTROROOM,
	SavePoint_Beehive,
	BeehiveRegular_SAVEINTROROOM,
	BlueBeehive_SAVEINTROROOM,
	BibleInteractPrompt_SAVEINTROROOM
}

enum Field
{
	InteractionCount,
	Deleted,
	Suffix,
	Deactivated
}

var data := {}

func get_id_name(id: ID) -> String:
	return ID.find_key(id)

func get_field_name(field: Field) -> String:
	return Field.find_key(field)

func set_data(id: ID, field: Field, setTo):
	if id == ID.Uninitialized: return
	var savedID = get_id_name(id)
	var savedField = get_field_name(field)
	if not savedID in data: data[savedID] = {}
	data[savedID][savedField] = setTo

func get_data(id: ID, field: Field):
	var defaultValue = get_default_field_value(field)
	var savedID = get_id_name(id)
	var savedField = get_field_name(field)
	if (not savedID in data) or (not savedField in data[savedID]):
		return defaultValue
	return data[savedID][savedField]

func get_incremented_data(id: ID, field: Field, add = 1):
	var new_data = get_data(id, field) + add
	set_data(id, field, new_data)
	return new_data

func get_default_field_value(field: Field):
	match field:
		Field.InteractionCount: return 0
		Field.Deleted: return false
		Field.Suffix: return ""
		Field.Deactivated: return false

func get_enum_from_str(wanted_enum_name: String) -> ID:
	return ID[wanted_enum_name]

func is_identifier_save_point(id: ID) -> bool:
	var id_name = get_id_name(id)
	return id_name.begins_with("SavePoint")
