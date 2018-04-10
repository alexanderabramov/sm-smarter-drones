local ImproveDemandRequestOriginal = Drone.ImproveDemandRequest

local function ImproveDemandRequest(self, s_request, d_request, resource, amount, must_change)
  status, d_request = xpcall(function()
    local command_center = self.command_center
    local d_building = d_request:GetBuilding()
    local priority
    if IsValid(d_building) then
      if d_request:IsAnyFlagSet(const.rfStorageDepot) then
        priority = 1
      else
        priority = d_building.priority + 1
      end
      if resource=="WasteRock" then
        -- hack: as we cannot override initial assignment of WasteRock disposal tasks, we override it now to look for the (closest) of the same priority
        priority = priority - 1
      end
    else
      must_change = true
    end
    if command_center and command_center.working then
      local ignore_flags = band(bnot(d_request:GetFlags()), const.rfSpecialDemandPairing + const.rfSpecialSupplyPairing)
      local d_request2 = command_center:FindDemandRequest(self, resource, amount, priority, ignore_flags)
      if d_request2 and d_request2:AssignUnit(amount) then
        d_request:UnassignUnit(amount, false)
        return d_request2
      end
    end
    if must_change then
      d_request:UnassignUnit(amount, false)
    else
      return d_request
    end
  end
  ,
  function(err)
    lcPrint(err)
    lcPrint(debug.traceback())
    return false
  end
	)
  return status and d_request
end

Drone.ImproveDemandRequest = ImproveDemandRequest
