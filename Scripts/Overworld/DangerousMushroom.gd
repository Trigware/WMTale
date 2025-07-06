extends Node

enum MushroomType {
	RED,
	GREEN
}

@export var mushroom_type : MushroomType

@onready var sprite = $Mushroom
@onready var light = $Light

func _ready():
	sprite.frame_coords.x = mushroom_type
	light.color = get_light_color()

func get_light_color():
	var base_color = Color.RED
	match mushroom_type:
		MushroomType.GREEN: base_color = Color.GREEN
	return base_color

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"): return
	mushroom_damage_behaviour()

func mushroom_damage_behaviour():
	match mushroom_type:
		MushroomType.RED: LeafMode.damage_using_id(LeafMode.DamageID.RedMushroom)
		MushroomType.GREEN: Effects.activate(Effects.ID.Poison)
