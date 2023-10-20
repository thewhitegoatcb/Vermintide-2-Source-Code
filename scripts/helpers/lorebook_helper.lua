LoreBookHelper = LoreBookHelper or { }
local new_pages = { }


function LoreBookHelper.save_new_pages()
	local save_data = SaveData
	local new_lorebook_ids = save_data.new_lorebook_ids or { }

	for category_name, _ in pairs(new_pages) do
		new_lorebook_ids [category_name] = true
	end

	save_data.new_lorebook_ids = new_lorebook_ids
	Managers.save:auto_save(SaveFileName, SaveData, nil)
end

function LoreBookHelper.mark_page_id_as_new(category_name)
	new_pages [category_name] = true
end

function LoreBookHelper.unmark_page_id_as_new(page_id)
	local save_data = SaveData
	local new_lorebook_ids = save_data.new_lorebook_ids
	assert(new_lorebook_ids, "Requested to unmark lorebook page id %d without any save data.", page_id)
	new_lorebook_ids [page_id] = nil
	Managers.save:auto_save(SaveFileName, SaveData, nil)
end

function LoreBookHelper.get_new_page_ids()
	return SaveData.new_lorebook_ids
end