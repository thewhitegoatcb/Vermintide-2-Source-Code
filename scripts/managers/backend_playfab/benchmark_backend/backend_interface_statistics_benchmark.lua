BackendInterfaceStatisticsBenchmark = class(BackendInterfaceStatisticsBenchmark)

function BackendInterfaceStatisticsBenchmark:update(dt)
	return end

function BackendInterfaceStatisticsBenchmark:init(mirror)
	return end

function BackendInterfaceStatisticsBenchmark:ready()
	return true
end

function BackendInterfaceStatisticsBenchmark:get_stats()
	return { }
end

function BackendInterfaceStatisticsBenchmark:clear_dirty_flags(stats)
	return end

function BackendInterfaceStatisticsBenchmark:save()
	return end

function BackendInterfaceStatisticsBenchmark:clear_saved_stats()
	return end

function BackendInterfaceStatisticsBenchmark:get_stat_save_request()
	return nil
end


function BackendInterfaceStatisticsBenchmark:reset()
	return end