local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

local PlatoonBuilder = Oxygen.PlatoonBuilder
local OpAIBuilder = Oxygen.OpAIBuilder
local UNIT = Oxygen.UnitNames.Get
local AdvancedBaseManager = Oxygen.BaseManager
local DifficultyValue = Oxygen.DifficultyValue
local DV = DifficultyValue.Get
local BC = Oxygen.BuildConditions

local SPAIFileName = '/lua/scenarioplatoonai.lua'
local YPAIFileName = '/maps/Test/YudiPlatoonAI.lua'


DifficultyValue.Extend {

    ["Engi Base count"] = { 10, 15, 20 },
    ["Engi Base assisters"] = { 7, 10, 12 },

    ["Brick count"] = { 3, 4, 5 },
    ["Banger count"] = { 1, 2, 3 },
    ["Deceiver count"] = { 0, 0, 1 },

    ["Rhino count"] = { 3, 4, 5 },

    ["M Brick count"] = { 6, 8, 10 },
    ["M Banger count"] = { 3, 4, 5 },
    ["M Deceiver count"] = { 0, 1, 2 },

    ["ASF attack count"] = { 15, 20, 25 },

    ["Flying Bricks count"] = { 5, 7, 10 },

    ["RAS Bois count"] = { 10, 30, 5 },

}

---@type AdvancedBaseManager
local neBase = Oxygen.BaseManager()
---@type AdvancedBaseManager
local swBase = Oxygen.BaseManager()
---@type AdvancedBaseManager
local seBase = Oxygen.BaseManager()


function NEBase()
    neBase:InitializeDifficultyTables(Oxygen.Brains.UEF, "M1_NE_Base", "M1_NE_Base_M", 100, { ["M1_NE_Base"] = 1000 })
    neBase:StartNonZeroBase { DV "Engi Base count", DV "Engi Base assisters" }
    neBase:SetActive('AirScouting', true)
    neBase:SetBuildAllStructures(true)


    neBase:SetBuildTransports(true)
    neBase.TransportsNeeded = 7
end

function SWBase()
    swBase:InitializeDifficultyTables(Oxygen.Brains.UEF, "M1_SW_Base", "M1_SW_Base_M", 65, { ["M1_SW_Base"] = 1000 })
    swBase:StartNonZeroBase { DV "Engi Base count", DV "Engi Base assisters" }
    swBase:SetActive('AirScouting', true)
    swBase:SetBuildAllStructures(true)


    swBase:SetBuildTransports(true)
    swBase.TransportsNeeded = 7
end


function SEBase()
    seBase:InitializeDifficultyTables(Oxygen.Brains.UEF, "M1_SE_Base", "M1_SE_Base_M", 100, { ["M1_SE_Base"] = 1000 })
    seBase:StartNonZeroBase { DV "Engi Base count", DV "Engi Base assisters" }
    seBase:SetActive('AirScouting', true)
    seBase:SetBuildAllStructures(true)


    seBase:SetBuildTransports(true)
    seBase.TransportsNeeded = 7
end

function Main()

    Oxygen.Game.Armies.CreateArmyGroup("UEF", 'M1_SW_Power', true)

    NEBase()
    SWBase()
    SEBase()
end
