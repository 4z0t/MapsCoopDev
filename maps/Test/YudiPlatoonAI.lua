---@param platoon Platoon
function BoiBuild(platoon)
    local aiBrain = platoon:GetBrain()
    local platoonUnits = platoon:GetPlatoonUnits()
    local data = platoon.PlatoonData
    while aiBrain:PlatoonExists(platoon) do

        LOG("Aboba")
        WaitTicks(Random(50, 100))
    end
end
