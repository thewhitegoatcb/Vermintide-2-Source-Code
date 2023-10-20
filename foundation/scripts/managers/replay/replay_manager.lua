


ReplayManager = class(ReplayManager)

function ReplayManager:init(world)
	self._world = world

	self._playing = true
	self._level_name = nil
	self._frame = 0
	self._frame_needs_drawing = false
	self._stories = { }
	self._current_story_index = nil
	self._current_story_id = nil
	self._frame_time = 0.016666666666666666
	self._have_had_proper_level = false
end


function ReplayManager:update(dt)
	local world_dt = 0
	if self._playing then

		local total = ExtendedReplay.num_frames()


		self._frame = self._frame + 1
		if self._frame == total then
			self._frame = 0
		end

		self:move_to_current_frame()


		world_dt = ExtendedReplay.delta_time()
	end

	if self._frame_needs_drawing then
		self:move_to_current_frame()
	end

	return world_dt
end



function ReplayManager:move_to_current_frame()

	ExtendedReplay.set_frame(self._frame)
	self._frame_needs_drawing = false


	self:report_frame()


	local new_story_index = nil
	for i, location in ipairs(self._stories) do
		if location.framestart <= self._frame and self._frame < location.frameend then
			new_story_index = i
			break
		end
	end

	local teller = self._world:storyteller()


	if new_story_index ~= self._current_story_index then

		if self._current_story_id ~= nil and
		teller:is_playing(self._current_story_id) then
			teller:stop(self._current_story_id)
		end



		self._current_story_index = new_story_index
		self._current_story_id = nil
	end


	if self._current_story_index ~= nil then
		local level = self._world:level_by_name(self._level_name)
		if level == nil then
			if not self._have_had_proper_level then

				local cmd = { action = "close", message = "error", type = "replay",


					reason = "Level " .. self._level_name .. " can't be found in the world. Have you loaded the correct level for this replay session?" }


				Application.console_send(cmd)

				self._have_had_proper_level = true
			end
		else
			self._have_had_proper_level = true
		end


		if level ~= nil then
			if self._current_story_id == nil or not teller:is_playing(self._current_story_id) then
				self._current_story_id = teller:play_level_story(level, self._stories [self._current_story_index].name)

				teller:set_speed(self._current_story_id, 0)
			end

			teller:set_time(self._current_story_id, ( self._frame - self._stories [self._current_story_index].framestart ) * self._frame_time)
		end
	end
end


function ReplayManager:report_frame()
	local cmd = { message = "frame", type = "replay",


		frame = self._frame }

	Application.console_send(cmd)
end



function ReplayManager:overriding_camera()
	if self._current_story_id ~= nil then
		local teller = self._world:storyteller()
		return teller:first_camera(self._current_story_id)
	end
end

function ReplayManager:reload()

	self._current_story_id = nil

	self._frame_needs_drawing = true
end

function ReplayManager:play(enable)
	self._playing = enable
end

function ReplayManager:set_frame(frame)
	self._frame = frame
	self._frame_needs_drawing = true
end

function ReplayManager:set_level(level)
	self._level_name = level
end

function ReplayManager:set_stories(stories)
	self._stories = stories
end