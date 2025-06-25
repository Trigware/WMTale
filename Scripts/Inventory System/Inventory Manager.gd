extends Node

enum Item
{
	NONE,
	GLOWING_MUSHROOM
}

enum ItemTier
{
	KEY
}

var ItemClassifications : Dictionary[Item, ItemTier] = {
	Item.GLOWING_MUSHROOM: ItemTier.KEY
}

func get_item_tier(item: Item) -> String:
	return ItemTier.find_key(ItemClassifications[item])

func get_item_name(item: Item) -> String:
	return Localization.get_text("itemname_" + get_item_enum(item))

func get_item_enum(item: Item) -> String:
	return Item.find_key(item)

func add_item(item: Item, count: int):
	var enumName = get_item_enum(item)
	if not SaveData.PlayerInventory.has(enumName): SaveData.PlayerInventory[enumName] = 0
	SaveData.PlayerInventory[enumName] += count
