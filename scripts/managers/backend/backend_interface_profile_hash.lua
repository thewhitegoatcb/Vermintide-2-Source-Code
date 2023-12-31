BackendInterfaceProfileHash = class(BackendInterfaceProfileHash)

function BackendInterfaceProfileHash:init()

	return end

function BackendInterfaceProfileHash:on_authenticated()
	local hash = Backend.get_hashed_profile_id()

	if hash ~= SaveData.backend_profile_hash then
		SaveData.backend_profile_hash = hash

		if SaveData.save_loaded then
			Managers.save:auto_save(SaveFileName, SaveData, nil)
		end
	end
end