




local ConflictDirectorTestify = {



	total_main_path_distance = function ()
		return EngineOptimized.main_path_total_length()
	end }




function ConflictDirectorTestify.get_all_breeds()
	local breeds = { }

	for breed_name, breed_data in pairs(Breeds) do
		if breed_data.is_always_spawnable and breed_data.allied ~= true then
			breeds [breed_name] = breed_data
		end
	end
	return breeds
end









function ConflictDirectorTestify.spawn_unit(conflict_director, unit_data)
	local boxed_spawn_rotation = QuaternionBox(Quaternion.identity())
	conflict_director:spawn_queued_unit(unit_data.breed_data, unit_data.boxed_spawn_position, boxed_spawn_rotation)
end




function ConflictDirectorTestify.get_unit_of_breed(conflict_director, breed_name)
	local _, unit = next(conflict_director:spawned_units_by_breed(breed_name))
	return unit
end



function ConflictDirectorTestify.destroy_all_units(conflict_director)
	conflict_director:destroy_all_units()
end




function ConflictDirectorTestify.peaks(conflict_director)
	return conflict_director:get_peaks()
end



function ConflictDirectorTestify.reset_terror_event_mixer()
	TerrorEventMixer.reset()
end




function ConflictDirectorTestify.terror_event_finished(conflict_director, event_name)
	return conflict_director:terror_event_finished(event_name)
end



function ConflictDirectorTestify.start_terror_event(conflict_director, event_name)
	conflict_director:start_terror_event(event_name)
end



function ConflictDirectorTestify.kill_nearby_enemies(conflict_director)
	conflict_director:destroy_close_units(nil, nil, 64)
end


return ConflictDirectorTestify