require("core/gwnav/lua/safe_require")
local NavGraph = safe_require_guard()

local NavClass = safe_require("core/gwnav/lua/runtime/navclass")
NavGraph = NavClass(NavGraph)

local GwNavGraph = stingray.GwNavGraph

function NavGraph:init(world, bidirectional_edges, point_table, color, layer_id, smartobject_id, user_data_id)
	self.nav_navgraph = GwNavGraph.create(world, bidirectional_edges, point_table, color, layer_id, smartobject_id, user_data_id)
end

function NavGraph:shutdown()
	GwNavGraph.destroy(self.nav_navgraph)
	self.nav_navgraph = nil
end

function NavGraph:add_to_database()
	GwNavGraph.add_to_database(self.nav_navgraph)
end

function NavGraph:remove_from_database()
	GwNavGraph.remove_from_database(self.nav_navgraph)
end

return NavGraph