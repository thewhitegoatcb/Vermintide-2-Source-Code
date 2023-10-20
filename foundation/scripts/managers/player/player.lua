Player = class(Player)


Player._allowed_transitions = {

	despawned = { spawned = true },
	queued_for_despawn = { despawned = true },
	spawned = { queued_for_despawn = true, despawned = true } }


function Player:init(network_manager, input_source, viewport_name, viewport_world_name, is_server)
	self.network_manager = network_manager
	self.input_source = input_source
	self.viewport_name = viewport_name
	self.viewport_world_name = viewport_world_name
	self.owned_units = { }
	self.is_server = is_server

	self.camera_follow_unit = nil


	self._spawn_state = "despawned"
end

function Player:destroy()
	self.network_manager = nil
end


function Player:set_camera_follow_unit(unit)
	self.camera_follow_unit = unit
end


function Player:needs_despawn()
	return self._spawn_state == "spawned"
end


function Player:mark_as_queued_for_despawn()
	self:_set_spawn_state("queued_for_despawn")
end

function Player:_set_spawn_state(state)
	fassert(state == "spawned" or state == "queued_for_despawn" or state == "despawned", "Invalid spawn state %s", state)
	fassert(Player._allowed_transitions [self._spawn_state] [state], "Spawn state transition from %s to %s is not allowed", self._spawn_state, state)
	self._spawn_state = state
end

function Player:spawn_state()
	return self._spawn_state
end