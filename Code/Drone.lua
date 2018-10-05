local ImproveDemandRequestOriginal = Drone.ImproveDemandRequest

local function ImproveDemandRequest(self, s_request, d_request, resource, amount, must_change)
  local status, d_request = xpcall(function()
    local command_center = self.command_center
    local d_building = d_request:GetBuilding()
    local priority, d_request2
    if IsValid(d_building) then
      priority = d_building:GetPriorityForRequest(d_request) + 1
      if resource=="WasteRock" then
        -- hack: as we cannot override initial assignment of WasteRock disposal tasks, we override it now to look for the (closest) of the same priority
        priority = priority - 1
      end
    else
      must_change = true
    end
    if command_center and command_center.working then
      local ignore_flags = band(bnot(d_request:GetFlags()), const.rfSpecialDemandPairing + const.rfSpecialSupplyPairing)
      d_request2 = command_center:FindDemandRequest(self, resource, amount, priority, ignore_flags)
    end

    local req_to_improve = d_request2 or d_request
    local assigned = true
    if req_to_improve:GetResource() ~= "WasteRock" and band(req_to_improve:GetFlags(), const.rfStorageDepot) == const.rfStorageDepot
    and (not s_request or band(s_request:GetFlags(), const.rfStorageDepot) == 0) then
      if not d_request2 then --unassign from d_req so improve storage dmnd works correctly for the depot the req belongs to
        req_to_improve:UnassignUnit(amount, false)
        assigned = false
      end
      local improved_req = ImproveStorageDemandRequest(self, amount, req_to_improve)

      if improved_req ~= req_to_improve then
        d_request2 = improved_req
      end
    end

    if d_request2 and d_request2:AssignUnit(amount) then
      if assigned then
        d_request:UnassignUnit(amount, false)
      end
      return d_request2
    end
    if must_change then
      if assigned then
        d_request:UnassignUnit(amount, false)
      end
      return
    else
      if not assigned then
        if not d_request:AssignUnit(amount) then
          return
        end
      end
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
