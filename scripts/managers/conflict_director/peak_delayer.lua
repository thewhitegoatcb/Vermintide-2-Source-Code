PeakDelayer = class(PeakDelayer)

local DISTANCE_TO_START_DELAY = 100
local TIME_TO_DELAY_PACING = 100
local PEAK_LENGTH = 30

local DELAY_STATES = { IN_PEAK = "IN_PEAK", DELAYING = "DELAYING", WAITING_TO_REACH_DELAY = "WAITING_TO_REACH_DELAY", DELAY_FINISHED = "DELAY_FINISHED" }






local function is_in_peak(peaks, current_travel_dist)
	for current_index = #peaks, 1, -1 do
		local peak = peaks [current_index]
		local inside_peak = math.value_inside_range(current_travel_dist, peak, peak + PEAK_LENGTH)
		if inside_peak then
			return true
		end
	end

	return false
end

local function get_next_peak(peaks, current_travel_dist)
	for i = #peaks, 1, -1 do
		if peaks [i] < current_travel_dist then
			return peaks [i + 1]
		end
	end

	return peaks [1]
end

function PeakDelayer:init(peaks)
	self._peaks = peaks
	self._state = DELAY_STATES.WAITING_TO_REACH_DELAY
end

function PeakDelayer:update(current_travel_dist, current_time)
	local next_peak = get_next_peak(self._peaks, current_travel_dist) or math.huge

	if self._state == DELAY_STATES.WAITING_TO_REACH_DELAY then
		if is_in_peak(self._peaks, current_travel_dist) then
			self._state = DELAY_STATES.IN_PEAK
		else
			local dist_to_peak = next_peak - current_travel_dist

			if dist_to_peak < DISTANCE_TO_START_DELAY then

				Managers.state.event:trigger("event_delay_pacing", true)
				self._delaying_since = current_time
				self._delay_for_peak = next_peak
				self._state = DELAY_STATES.DELAYING
			end
		end
	elseif self._state == DELAY_STATES.DELAYING then
		if is_in_peak(self._peaks, current_travel_dist) then
			Managers.state.event:trigger("event_delay_pacing", false)
			self._state = DELAY_STATES.IN_PEAK

		elseif self._delay_for_peak ~= next_peak then
			Managers.state.event:trigger("event_delay_pacing", false)
			self._delay_for_peak = nil
			self._state = DELAY_STATES.WAITING_TO_REACH_DELAY
		elseif TIME_TO_DELAY_PACING < current_time - self._delaying_since then
			Managers.state.event:trigger("event_delay_pacing", false)
			self._state = DELAY_STATES.DELAY_FINISHED
		end

	elseif self._state == DELAY_STATES.DELAY_FINISHED then
		if is_in_peak(self._peaks, current_travel_dist) then
			self._state = DELAY_STATES.IN_PEAK
		elseif self._delay_for_peak ~= next_peak then
			self._delay_for_peak = nil
			self._state = DELAY_STATES.WAITING_TO_REACH_DELAY
		end

	elseif self._state == DELAY_STATES.IN_PEAK and
	not is_in_peak(self._peaks, current_travel_dist) then
		self._state = DELAY_STATES.WAITING_TO_REACH_DELAY
	end


	if script_data.debug_peak_delayer then
		Debug.text("PeakDelayer state: %s", self._state)
	end
end

function PeakDelayer:is_near_or_in_a_peak()
	return self._state ~= DELAY_STATES.WAITING_TO_REACH_DELAY
end

function PeakDelayer:set_peaks(peaks)
	self._peaks = table.clone(peaks)
end

function PeakDelayer:get_peaks()
	return self._peaks and table.clone(self._peaks) or { }
end