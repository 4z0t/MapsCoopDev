local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local TauntManager = import('/lua/TauntManager.lua')
local PlatoonBuilder = Oxygen.PlatoonBuilder
local UNIT = Oxygen.UnitNames.Get
local BC = Oxygen.BuildConditions
local BaseManager = Oxygen.BaseManager.BaseManagers.AdvancedBaseManager

local SPAIFileName = '/lua/scenarioplatoonai.lua'


local tauntUEF = TauntManager.CreateTauntManager("UEF", Oxygen.ScenarioFolder "VOStrings.lua")

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
DV.M1_NE_MMLs = { 3, 5, 8 }


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
    neBase:SetTransportsTech(2)
    neBase.TransportsNeeded = 3

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
        pb:New "NE Pillar attack"
            :Priority(200)
            :InstanceCount(4)
            :AddUnit(UNIT "Pillar", DV.M1_NE_Pillars)
            :AddUnit(UNIT "Parashield", DV.M1_NE_Shield)
            :AddUnit(UNIT "T2 UEF Flak", DV.M1_NE_Flak)
            :Create(),

        pb:New "ArtyDrop"
            :Priority(100)
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

        pb:New "NE MMLs"
            :Priority(200)
            :InstanceCount(3)
            :AddUnit(UNIT "T2 UEF MML", DV.M1_NE_MMLs, 'Artillery')
            :AddUnit(UNIT "Parashield", DV.M1_NE_Shield, 'Guard')
            :AddCondition(BC.HumansCategoryCondition(categories.DEFENSE * categories.LAND, ">=", 10))
            :Create()

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
    swBase:SetTransportsTech(2)
    swBase.TransportsNeeded = 3
end

DV.M1_SE_EngineerCount = { 10, 20, 30 }
DV.M1_SE_AssisterCount = { 7, 15, 20 }


DV.M1_SE_Titans = { 3, 4, 5 }
DV.M1_SE_Bombers = { 3, 4, 5 }
DV.M1_SE_Gunships = { 3, 4, 5 }

DV.M1_SE_BuildAirDefenses = { false, false, true }
DV.M1_SE_BuildLandDefenses = { false, false, true }

DV.M1_SE_PercivalCount = { 1, 2, 4 }
DV.M1_SE_PercivalShieldsCount = { 1, 3, 6 }

DV.M1_SE_HeavyGunships = { 3, 5, 10 }
DV.M1_SE_HeavyGunshipsSupportASFs = { 0, 10, 15 }
DV.M1_SE_ASFs = { 0, 20, 30 }
DV.M1_SE_Strats = { 2, 5, 8 }


function SEBase()
    ScenarioInfo.UEFacu = Oxygen.Game.Armies.CreateUnit("UEF", "UEF_ACU")

    seBase:InitializeDifficultyTables(Oxygen.Brains.UEF, "M1_SE_Base", "M1_SE_Base_M", 150, { ["M1_SE_Base"] = 1000 })
    seBase:StartNonZeroBase { DV.M1_SE_EngineerCount, DV.M1_SE_AssisterCount }
    seBase:SetActive('AirScouting', true)
    seBase:SetBuildAllStructures(true)
    seBase:SetACUUpgrades(
        {
            "Shield",
            "T3Engineering",
            "ResourceAllocation"
        }, true)

    seBase:SetBuildTransports(true)
    seBase:SetTransportsTech(3)
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
            pb:New "SE Titan attack"
                :AddUnit(UNIT "Titan", DV.M1_SE_Titans)
                :Priority(200)
                :InstanceCount(4)
                :Create(),

            pb:New "SE Percy attack"
                :Priority(300)
                :InstanceCount(4)
                :Difficulty { "Hard", "Medium" }
                :AddUnit(UNIT "Percival", DV.M1_SE_PercivalCount)
                :AddUnit(UNIT "Parashield", DV.M1_SE_PercivalShieldsCount, 'Guard')
                :AddCondition(BC.HumansEconomyCondition("MassIncome", ">=", 100))
                :Create()
        }
    end

    do --air platoons
        ---@type PlatoonTemplateBuilder
        local pb = PlatoonBuilder()

        pb
            :UseAIFunction(Oxygen.PlatoonAI.Common, "PatrolChainPickerThread")
            :UseType "Air"
            :UseData
            {
                PatrolChains = {
                    "M1_AAC2",
                },
                Offset = 30
            }


        seBase:LoadPlatoons
        {
            pb:New "SE T1 bomber attack"
                :AddUnit(UNIT "T1 UEF Bomber", DV.M1_SE_Bombers)
                :Priority(200)
                :InstanceCount(4)
                :Create(),

            pb:New "SE Gunship attack"
                :AddUnit(UNIT "T2 UEF Gunship", DV.M1_SE_Gunships)
                :Priority(100)
                :InstanceCount(2)
                :Create(),

            pb:New "SE Heavy gunships"
                :Priority(500)
                :InstanceCount(1)
                :Difficulty { "Hard", "Medium" }
                :AddUnit(UNIT "<TODO heavy gunship>", DV.M1_SE_HeavyGunships, "Attack", "GrowthFormation")
                :AddUnit(UNIT "<TODO Asf>", DV.M1_SE_HeavyGunshipsSupportASFs, 'Support', "GrowthFormation")
                :AddCondition(BC.HumansEconomyCondition("MassIncome", ">=", 250))
                :AIFunction(SPAIFileName, 'CategoryHunterPlatoonAI')
                :Data
                {
                    CategoryList =
                    {
                        (categories.DEFENSE + categories.MOBILE) * categories.ANTIAIR,
                        categories.SHIELD * categories.STRUCTURE,
                        categories.MASSFABRICATION,
                        categories.MASSEXTRACTION,
                        categories.ENERGYPRODUCTION
                    }
                }
                :Create(),

            pb:New "SE ASFs"
                :Priority(1000)
                :InstanceCount(2)
                :Difficulty { "Hard", "Medium" }
                :AddUnit(UNIT "<TODO Asf>", DV.M1_SE_Strats, 'Attack', "GrowthFormation")
                :AddCondition(BC.HumansCategoryCondition(categories.AIR, ">=", 20))
                :AIFunction(SPAIFileName, 'CategoryHunterPlatoonAI')
                :Data
                {
                    CategoryList = { categories.AIR }
                }
                :Create(),

            pb:New "SE Strats"
                :Priority(1500)
                :InstanceCount(3)
                :AddUnit(UNIT "<TODO t3 uef bomber>", DV.M1_SE_ASFs, 'Attack', "GrowthFormation")
                :AddCondition(BC.HumansEconomyCondition("MassIncome", ">=", 300))
                :AIFunction(SPAIFileName, 'CategoryHunterPlatoonAI')
                :Data
                {
                    CategoryList =
                    {
                        categories.MASSFABRICATION,
                        categories.MASSEXTRACTION,
                        categories.ENERGYPRODUCTION
                    }
                }
                :Create(),

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

    tauntUEF:AddPlayerIntelCategoryTaunt("M1_UEF_Locate_Taunt", Oxygen.Brains.UEF, categories.ALLUNITS)

    NEBase()
    SWBase()
    SEBase()
end
