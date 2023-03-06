local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

local PlatoonBuilder = Oxygen.PlatoonBuilder
local UNIT = Oxygen.UnitNames.Get
local AdvancedBaseManager = Oxygen.BaseManager
local DifficultyValue = Oxygen.DifficultyValue
local DV = DifficultyValue.Get
local BC = Oxygen.BuildConditions

local SPAIFileName = '/lua/scenarioplatoonai.lua'
local YPAIFileName = '/maps/Test/YudiPlatoonAI.lua'

---@type AdvancedBaseManager
local neBase = Oxygen.BaseManager()
---@type AdvancedBaseManager
local swBase = Oxygen.BaseManager()
---@type AdvancedBaseManager
local seBase = Oxygen.BaseManager()



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

    ["Build Additional Land defenses"] = { false, false, true },
    ["Build Additional Air defenses"] = { false, false, true },


    ["M1 NE Pillars"] = { 4, 5, 6 },

    -- ["M1 NE flak"]={0,1,2},

    -- ["M1 NE "]={}

}
local DiffValues = Oxygen.DifficultyValues
DiffValues.M1_NE_Pillars = { 4, 5, 6 }
DiffValues.M1_NE_Flak = { 0, 1, 2 }
DiffValues.M1_NE_Shield = { 1, 2, 3 }
DiffValues.M1_NE_LoboDrop = { 8, 12, 16 }




function NEBase()
    neBase:InitializeDifficultyTables(Oxygen.Brains.UEF, "M1_NE_Base", "M1_NE_Base_M", 100,
        {
            ["M1_NE_Base"] = 1000
        }
    )
    neBase:StartNonZeroBase { DV "Engi Base count", DV "Engi Base assisters" }
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
            :AddUnit(UNIT "Pillar", DiffValues.M1_NE_Pillars)
            :AddUnit(UNIT "Parashield", DiffValues.M1_NE_Shield)
            :AddUnit(UNIT "T2 UEF Flak", DiffValues.M1_NE_Flak)
            :Create(),

        pb:NewDefault "ArtyDrop"
            :Priority(200)
            :AddUnit(UNIT "Lobo", DiffValues.M1_NE_LoboDrop)
            :BuildOnce()
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

function SWBase()
    swBase:InitializeDifficultyTables(Oxygen.Brains.UEF, "M1_SW_Base", "M1_SW_Base_M", 65,
        {
            ["M1_SW_Base"] = 1000
        }
    )
    swBase:StartNonZeroBase { DV "Engi Base count", DV "Engi Base assisters" }
    swBase:SetActive('AirScouting', true)
    swBase:SetBuildAllStructures(true)


    swBase:SetBuildTransports(true)
    swBase.TransportsNeeded = 7
end

DiffValues.M1_SE_Titans = { 3, 4, 5 }
DiffValues.M1_SE_Bombers = { 3, 4, 5 }
DiffValues.M1_SE_Gunships = { 3, 4, 5 }



function SEBase()
    seBase:InitializeDifficultyTables(Oxygen.Brains.UEF, "M1_SE_Base", "M1_SE_Base_M", 150, { ["M1_SE_Base"] = 1000 })
    seBase:StartNonZeroBase { DV "Engi Base count", DV "Engi Base assisters" }
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
                :AddUnit(UNIT "Titan", DiffValues.M1_SE_Titans)
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
                :AddUnit(UNIT "T1 UEF Bomber", DiffValues.M1_SE_Bombers)
                :Priority(200)
                :InstanceCount(4)
                :Create(),

            pb:NewDefault "SE Gunship attack"
                :AddUnit(UNIT "T2 UEF Gunship", DiffValues.M1_SE_Gunships)
                :Priority(100)
                :InstanceCount(2)
                :Create()


        }
    end








    if DV "Build Additional Air defenses" then
        seBase:AddBuildStructures("M1_SE_Air", {
            Priority = 2000,
            BuildConditions =
            {
                BC.HumansCategoryCondition(categories.AIR, ">=", 30),
                BC.HumansBuiltOrActiveCategoryCondition(categories.AIR * categories.EXPERIMENTAL, ">", 0)
            }
        })
    end

    if DV "Build Additional Land defenses" then

        seBase:AddBuildStructures("M1_SE_Land", {
            Priority = 1800,
            BuildConditions =
            {
                BC.HumansCategoryCondition(categories.LAND, ">=", 30)
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
