extends Node

var status_effect = preload("res://Scenes/Status Effect.tscn")

enum ID {
	Uninitialized,
	Poison
}

func activate(id: ID, duration):
	var effect_instance = status_effect.instantiate()
	effect_instance.effect = id
	add_child(effect_instance)

func get_effect_name(id: ID) -> String:
	return ID.find_key(id)
