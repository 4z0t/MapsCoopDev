---@param platoon Platoon
function BoiBuild(platoon)
    local aiBrain = platoon:GetBrain()
    local platoonUnits = platoon:GetPlatoonUnits()
    local data = platoon.PlatoonData
    ---@type AdvancedBaseManager
    local baseManager = aiBrain.BaseManagers[platoon.LocationType]
    --baseManager:AddOpAI()
end
