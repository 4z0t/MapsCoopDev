local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local PlatoonBuilder = Oxygen.PlatoonBuilder
local UNIT = Oxygen.UnitNames.Get
local BC = Oxygen.BuildConditions
local BaseManager = Oxygen.BaseManager.BaseManagers.AdvancedBaseManager

local SPAIFileName = '/lua/scenarioplatoonai.lua'


---@type AdvancedBaseManager
local neBase = BaseManager()
---@type AdvancedBaseManager
local swBase = BaseManager()
---@type AdvancedBaseManager
local seBase = BaseManager()


local DV = Oxygen.DifficultyValues


DV.M1_NE_EngineersCount = { 7, 10, 15 }
DV.M1_NE_AssistersCount = { 5, 7, 10 }

DV.M1_NE_Pillars = { 4, 5, 6 }
DV.M1_NE_Flak = { 0, 1, 2 }
DV.M1_NE_Shield = { 1, 2, 3 }
DV.M1_NE_LoboDrop = { 8, 12, 16 }


function NEBase()
    neBase:InitializeDifficultyTables(Oxygen.Brains.UEF, "M1_NE_Base", "M1_NE_Base_M", 100,
        {
            ["M1_NE_Base"] = 1000
        }
    )
    neBase:StartNonZeroBase { DV.M1_NE_EngineersCount, DV.M1_NE_AssistersCount }
    neBase:SetActive('AirScouting', true)
    neBase:SetBuildAllStructures(true)
    neBase:SetBuildTransports(true)
    neBase.TransportsNeeded = 7

    ---@type PlatoonTemplateBuilder
    local pb = PlatoonBuilder()

    pb
        :UseAIFunction(SPAIFileName, "PatrolChainPickerThread")
        :UseType "Land"
        :UseData
        {
            PatrolChains = {
                "M1_LAC7",
                "M1_LAC5",
                "M1_LAC4",
            }
        }

    neBase:LoadPlatoons
    {
        pb:NewDefault "NE Pillar attack"
            :Priority(100)
            :InstanceCount(4)
            :AddUnit(UNIT "Pillar", DV.M1_NE_Pillars)
            :AddUnit(UNIT "Parashield", DV.M1_NE_Shield)
            :AddUnit(UNIT "T2 UEF Flak", DV.M1_NE_Flak)
            :Create(),

        pb:NewDefault "ArtyDrop"
            :Priority(200)
            :AddUnit(UNIT "Lobo", DV.M1_NE_LoboDrop)
            :AIFunction('/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports')
            :Data
            {
                TransportReturn = "M1_NE_Base_M",
                TransportChain = "M1_LTC2",
                LandingChain = "M1_LLC1",
                AttackChain = "Spawn_AC"
            }
            :Create(),
    }

end

DV.M1_SW_EngineerCount = { 4, 7, 10 }
DV.M1_SW_AssisterCount = { 2, 4, 6 }

function SWBase()
    swBase:InitializeDifficultyTables(Oxygen.Brains.UEF, "M1_SW_Base", "M1_SW_Base_M", 65,
        {
            ["M1_SW_Base"] = 1000
        }
    )
    swBase:StartNonZeroBase { DV.M1_SW_EngineerCount, DV.M1_SW_AssisterCount }
    swBase:SetActive('AirScouting', true)
    swBase:SetBuildAllStructures(true)


    swBase:SetBuildTransports(true)
    swBase.TransportsNeeded = 7
end

DV.M1_SE_EngineerCount = { 10, 20, 30 }
DV.M1_SE_AssisterCount = { 7, 15, 20 }


DV.M1_SE_Titans = { 3, 4, 5 }
DV.M1_SE_Bombers = { 3, 4, 5 }
DV.M1_SE_Gunships = { 3, 4, 5 }

DV.M1_SE_BuildAirDefenses = { false, false, true }
DV.M1_SE_BuildLandDefenses = { false, false, true }


function SEBase()
    seBase:InitializeDifficultyTables(Oxygen.Brains.UEF, "M1_SE_Base", "M1_SE_Base_M", 150, { ["M1_SE_Base"] = 1000 })
    seBase:StartNonZeroBase { DV.M1_SE_EngineerCount, DV.M1_SE_AssisterCount }
    seBase:SetActive('AirScouting', true)
    seBase:SetBuildAllStructures(true)


    seBase:SetBuildTransports(true)
    seBase.TransportsNeeded = 2
    seBase.MaximumConstructionEngineers = 15



    do --land platoons

        ---@type PlatoonTemplateBuilder
        local pb = PlatoonBuilder()

        pb
            :UseAIFunction(SPAIFileName, "PatrolChainPickerThread")
            :UseType "Land"
            :UseData
            {
                PatrolChains = {
                    "M1_LAC3",
                    "M1_LAC6",
                }
            }


        seBase:LoadPlatoons
        {
            pb:NewDefault "SE Titan attack"
                :AddUnit(UNIT "Titan", DV.M1_SE_Titans)
                :Priority(200)
                :InstanceCount(4)
                :Create()


        }
    end

    do --air platoons
        ---@type PlatoonTemplateBuilder
        local pb = PlatoonBuilder()

        pb
            :UseAIFunction(SPAIFileName, "PatrolChainPickerThread")
            :UseType "Air"
            :UseData
            {
                PatrolChains = {
                    "M1_AAC2",
                }
            }


        seBase:LoadPlatoons
        {
            pb:NewDefault "SE T1 bomber attack"
                :AddUnit(UNIT "T1 UEF Bomber", DV.M1_SE_Bombers)
                :Priority(200)
                :InstanceCount(4)
                :Create(),

            pb:NewDefault "SE Gunship attack"
                :AddUnit(UNIT "T2 UEF Gunship", DV.M1_SE_Gunships)
                :Priority(100)
                :InstanceCount(2)
                :Create()


        }
    end


    if DV.M1_SE_BuildAirDefenses then
        seBase:AddBuildStructures("M1_SE_Air", {
            Priority = 2000,
            BuildConditions =
            {
                BC.HumansCategoryCondition(categories.AIR, ">=", 30),
                BC.HumansBuiltOrActiveCategoryCondition(categories.AIR * categories.EXPERIMENTAL, ">", 0)
            }
        })
    end

    if DV.M1_SE_BuildLandDefenses then
        seBase:AddBuildStructures("M1_SE_Land", {
            Priority = 1800,
            BuildConditions =
            {
                BC.HumansCategoryCondition(categories.LAND * categories.MOBILE, ">=", 30)
            }
        })
    end
end

function Main()

    Oxygen.Game.Armies.CreateArmyGroup("UEF", 'M1_SW_Power', true)

    NEBase()
    SWBase()
    SEBase()
end
