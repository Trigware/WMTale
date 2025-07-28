extends Node

var follower_agents := {}
const follower_distance = 35

func _process(_delta):
	update_followers_zindex()

func create_simple_moving_npc(agent_type, agent_variation := Enum.AgentVariation.NoVariation):
	if agent_type == Enum.AgentType.PlayerAgent: Player.inputless_movement = true
	var instance = UID.SCN_MOVINGNPC.instantiate()
	instance.agent_type = agent_type
	instance.agent_variation = agent_variation
	add_child(instance)
	return instance

func initialize_player_agent(instance, x, y, to, final_look_dir, speed):
	instance.speed = speed
	instance.final_look_dir = final_look_dir
	if to: await instance.move_to(x, y)
	else: await instance.move_by(x, y)
	instance.queue_free()
	Player.inputless_movement = false

func move_player(x, y, to, final_look_dir, speed):
	var instance = create_simple_moving_npc(Enum.AgentType.PlayerAgent)
	initialize_player_agent(instance, x, y, to, final_look_dir, speed)

func move_player_by(x, y = 0, speed = 1, final_look_dir := Vector2.ZERO):
	move_player(x, y, false, final_look_dir, speed)

func move_player_to(x, y, speed = 1, final_look_dir := Vector2.ZERO):
	move_player(x, y, true, final_look_dir, speed)

func get_agent_type_name(agent_type: Enum.AgentType):
	return Enum.AgentType.find_key(agent_type)

func refresh_follower_agents():
	Player.footsteps.clear()
	for agent_name in follower_agents.keys():
		var agent = follower_agents[agent_name]
		agent.queue_free()
	for agent_variation_str in Overworld.party_members:
		var agent_variation = MovingNPC.convert_str_to_agent_variation(agent_variation_str)
		create_follower_agent(agent_variation)

func create_follower_agent(agent_variation: Enum.AgentVariation):
	follower_agents[agent_variation] = create_simple_moving_npc(Enum.AgentType.FollowerAgent, agent_variation)

func check_for_follower_movement():
	var agent_index = 1
	var last_index = Player.footsteps.size() - 1
	for agent_name in follower_agents.keys():
		var agent = follower_agents[agent_name]
		var target_index = last_index - follower_distance * agent_index
		if target_index < 0: continue
		var footstep = Player.footsteps[target_index]
		agent.take_step_towards_player(footstep)
		agent_index += 1

func update_followers_zindex():
	var player_followers_arr := []
	player_followers_arr.append({"follower": Player.node, "y": Player.get_body_pos().y})
	for follower in follower_agents.values():
		player_followers_arr.append({"follower": follower, "y": follower.position.y})
	player_followers_arr.sort_custom(
		func(a, b): return a["y"] < b["y"]
	)
	
	var sorted_follower_index = 0
	for sorted_follower_info in player_followers_arr:
		var follower = sorted_follower_info["follower"]
		follower.z_index = follower.base_follower_zindex + sorted_follower_index
		sorted_follower_index += 1

func get_follower_agent_with_index(index):
	var follower_name = Overworld.party_members[index]
	return follower_agents[follower_name]

func get_agent_variation_as_str(agent_variation: Enum.AgentVariation) -> String:
	return Enum.AgentVariation.find_key(agent_variation)

func convert_str_to_agent_variation(agent_variation: String) -> Enum.AgentVariation:
	return Enum.AgentVariation[agent_variation]

func set_texture_height(anim_node, uniform_func_scope):
	await get_tree().process_frame
	var spr_frames = anim_node.sprite_frames
	var frame_texture = spr_frames.get_frame_texture(anim_node.animation, anim_node.frame)
	if frame_texture == null: return
	var texture_size = frame_texture.get_size()
	uniform_func_scope.set_uniform("image_pixel_height", texture_size.y)
	return texture_size.y
