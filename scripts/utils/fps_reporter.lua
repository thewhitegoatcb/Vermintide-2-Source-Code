FPSReporter = class(FPSReporter)
FPSReporter.NAME = "FPSReporter"

local NUM_BUCKETS = 10

function FPSReporter:init()
	self._avg_fps = 0
	self._histogram = { }
	self._num_frames = 1

	for i = 1, NUM_BUCKETS + 1 do
		self._histogram [i] = 0
	end
end

function FPSReporter:update(dt, t)
	local fps = 1 / math.max(dt, 0.001)

	self:_update_average_fps(fps)
	self:_update_histogram(fps)

	self._num_frames = self._num_frames + 1
end

function FPSReporter:_update_average_fps(fps)

	self._avg_fps = ( fps + self._avg_fps * (self._num_frames - 1) ) / self._num_frames
end







function FPSReporter:_update_histogram(fps)
	local bucket_index = math.clamp(math.ceil(fps / NUM_BUCKETS), 1, NUM_BUCKETS + 1)
	self._histogram [bucket_index] = self._histogram [bucket_index] + 1
end

function FPSReporter:report()
	self:_normalize_histogram()
	Managers.telemetry_events:fps(self._avg_fps, self._histogram)
end

function FPSReporter:avg_fps()
	return self._avg_fps
end

function FPSReporter:_normalize_histogram()
	local num_frames = 0

	for _, count in pairs(self._histogram) do
		num_frames = num_frames + count
	end


	num_frames = math.max(num_frames, 1)

	for i, _ in pairs(self._histogram) do
		self._histogram [i] = self._histogram [i] / num_frames
	end
end