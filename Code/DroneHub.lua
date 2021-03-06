local MaxBuildingPriority     = const.MaxBuildingPriority
local rfConstruction = const.rfConstruction
local rfRestrictorRocket = const.rfRestrictorRocket
local rfPairWithHigher = const.rfPairWithHigher

local function Request_FindDemand_WasteRock(demand_queues, under_construction, restrictor_t, resource, amount, min_priority, ignore_flags, required_flags, requestor_prio, exclude_building, unreachable_buildings, reference_point)
  requestor_prio = requestor_prio or MaxBuildingPriority + 1
  required_flags = required_flags or 0
  ignore_flags = ignore_flags or 0
  min_priority = min_priority or -1

  for j = MaxBuildingPriority, (min_priority or -1), -1 do
    local requests = demand_queues[j][resource]
    if requests then
      local index = requests.index or 1
      local closest_distance, closest_request, closest_amount = -1
      for _ = 1, #requests do
        if index > #requests then index = 1 end
        local request = requests[index]
        index = index + 1
        local r_amount, flags, building = request:GetTargetAmount(), request:GetFlags(), request:GetBuilding()
        if r_amount>0 and request:GetFreeUnitSlots() > 0 and exclude_building ~= building
        and r_amount >= amount
        and (not IsFlagSet(flags, rfConstruction) or under_construction[resource] == request)
        and (not IsFlagSet(flags, rfRestrictorRocket) or (restrictor_t[rfRestrictorRocket] and restrictor_t[rfRestrictorRocket][resource] == request))
        and (not IsFlagSet(flags, rfPairWithHigher) or requestor_prio > j)
        and band(required_flags, flags) == required_flags
        and band(ignore_flags, flags) == 0
        then
          local distance = building:GetDist2D(reference_point)
          if closest_distance == -1 or distance < closest_distance then
            closest_distance, closest_request, closest_amount = distance, request, Min(r_amount, amount)
          end
        end
      end
      if closest_distance > -1 then
        return closest_request, closest_amount
      end
    end
  end
end

local FindDemandRequestOriginal = DroneControl.FindDemandRequest

local function FindDemandRequest(self, drone, resource, amount, min_priority, ignore_flags, required_flags, requestor_prio, exclude_building)
  local status, res_request, res_amount = xpcall(function()
    if resource ~= "WasteRock" then
      return FindDemandRequestOriginal(self, drone, resource, amount, min_priority, ignore_flags, required_flags, requestor_prio, exclude_building)
    end

    min_priority = min_priority or -1
    requestor_prio = requestor_prio or MaxBuildingPriority + 1
    required_flags = required_flags or 0
    ignore_flags = ignore_flags or 0
    assert(self.under_construction)
    local reference_point = drone:GetPos()

    return Request_FindDemand_WasteRock(self.demand_queues, self.under_construction or empty_table, self.restrictor_tables or empty_table, resource, amount,
    min_priority, ignore_flags, required_flags, requestor_prio, exclude_building, drone.unreachable_buildings, reference_point)
  end
  ,
  function(err)
    lcPrint(err)
    lcPrint(debug.traceback())
    return false
  end
)
return status and res_request, status and res_amount
end

DroneControl.FindDemandRequest = FindDemandRequest
