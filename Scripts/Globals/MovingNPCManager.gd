extends Node

enum AgentType {
	Uninitialized,
	PlayerAgent,
	FollowerAgent
}

var follower_agents := {}
const follower_distance = 50

func create_simple_moving_npc(agent_type, agent_variation := ""):
	if agent_type == AgentType.PlayerAgent: Player.inputless_movement = true
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
	var instance = create_simple_moving_npc(AgentType.PlayerAgent)
	initialize_player_agent(instance, x, y, to, final_look_dir, speed)

func move_player_by(x, y = 0, speed = 1, final_look_dir := Vector2.ZERO):
	move_player(x, y, false, final_look_dir, speed)

func move_player_to(x, y, speed = 1, final_look_dir := Vector2.ZERO):
	move_player(x, y, true, final_look_dir, speed)

func get_agent_type_name(agent_type: AgentType):
	return AgentType.find_key(agent_type)

func create_all_follower_agents():
	for agent_variation in Overworld.party_members:
		create_follower_agent(agent_variation)

func create_follower_agent(agent_variation: String):
	follower_agents[agent_variation] = create_simple_moving_npc(AgentType.FollowerAgent, agent_variation)

func check_for_follower_movement():
	for agent_name in follower_agents.keys():
		var agent = follower_agents[agent_name]
		var target_index = Player.footstep_targets.size() - 1 - follower_distance
		if abs(target_index) > Player.footstep_targets.size(): continue
		var target = Player.footstep_targets[target_index]
		agent.take_step_towards_player(target)
