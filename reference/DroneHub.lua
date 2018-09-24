local MaxBuildingPriority     = const.MaxBuildingPriority

local Request_FindDemand_C = Request_FindDemand
--[[
function Request_FindDemand_Lua(demand_queues, under_construction, restrictor_t, resource, amount, min_priority, ignore_flags, required_flags, requestor_prio, exclude_building)
	requestor_prio = requestor_prio or MaxBuildingPriority + 1
	required_flags = required_flags or 0
	ignore_flags = ignore_flags or 0
	min_priority = min_priority or -1

	for j = MaxBuildingPriority, (min_priority or -1), -1 do
		local requests = demand_queues[j][resource]
		if requests then
			local index = requests.index or 1
			for _ = 1, #requests do
				if index > #requests then index = 1 end
				local request = requests[index]
				index = index + 1
				local r_amount, flags = request:GetTargetAmount(), request:GetFlags()
				if r_amount>0 and request:GetFreeUnitSlots() > 0 and exclude_building ~= request:GetBuilding()
					and r_amount >= amount
 					and (not IsFlagSet(flags, rfConstruction) or under_construction[resource] == request)
					and (not IsFlagSet(flags, rfRestrictorRocket) or (restrictor_t[rfRestrictorRocket] and restrictor_t[rfRestrictorRocket][resource] == request))
					and (not IsFlagSet(flags, rfPairWithHigher) or requestor_prio > j)
					and band(required_flags, flags) == required_flags
					and band(ignore_flags, flags) == 0
				then
					--requests.index = index
					return request, Min(r_amount, amount)
				end
			end
			--requests.index = index
		end
	end
end
local function Request_FindDemand(demand_queues, under_construction, restrictor_t, resource, amount, ...)
	local r1, a1 = Request_FindDemand_Lua(demand_queues, under_construction, restrictor_t, resource, amount, ...)
	local r2, a2 = Request_FindDemand_C(demand_queues, under_construction, restrictor_t, resource, amount, ...)
	assert(r1 == r2)
	return r2, a2
end
--]]

function DroneControl:FindDemandRequest(drone, resource, amount, min_priority, ignore_flags, required_flags, requestor_prio, exclude_building)
	min_priority = min_priority or -1
	requestor_prio = requestor_prio or MaxBuildingPriority + 1
	required_flags = required_flags or 0
	ignore_flags = ignore_flags or 0
	assert(self.under_construction)
	return Request_FindDemand_C(self.demand_queues, self.under_construction or empty_table, self.restrictor_tables or empty_table, resource, amount,
		min_priority, ignore_flags, required_flags, requestor_prio, exclude_building, drone.unreachable_buildings)
end
