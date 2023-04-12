local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local TauntManager = import('/lua/TauntManager.lua')
local PlatoonBuilder = Oxygen.PlatoonBuilder
local UNIT = Oxygen.UnitNames.Get
local BC = Oxygen.BuildConditions
local BaseManager = Oxygen.BaseManagers.CustomBaseManager

local PARSE = Oxygen.UnitNames.FactionParse.FactionUnitParser("UEF")

local SPAIFileName = '/lua/scenarioplatoonai.lua'
local DV = Oxygen.DifficultyValues


local tauntUEF = TauntManager.CreateTauntManager("UEF", Oxygen.ScenarioFolder "VOStrings.lua")

---@type CustomBaseManager
local neBase = BaseManager()
---@type CustomBaseManager
local swBase = BaseManager()
---@type CustomBaseManager
local seBase = BaseManager()

---@type NukeBaseManger
local nukeBase = Oxygen.BaseManagers.NukeBaseManger()



function NukeBase()
    nukeBase:Initialize(Oxygen.Brains.UEF, "M1_Nuke_Base", "M1_Nuke_Base_M", 10, {
        ["M1_Nuke_Base"] = 1000,
        ["M1_Nuke_Stealth"] = 2000,
    })
    nukeBase:StartEmptyBase(5)
    nukeBase:SortGroupNames()

    nukeBase:SetBuildAllStructures(true)
    nukeBase:SetActive('Nuke', true)

    nukeBase.MaximumConstructionEngineers = 5
end

DV.M1_NE_EngineersCount = { 7, 10, 15 }
DV.M1_NE_AssistersCount = { 5, 7, 10 }

DV.M1_NE_Pillars = { 4, 5, 6 }
DV.M1_NE_Flak = { 0, 1, 2 }
DV.M1_NE_Shield = { 1, 2, 3 }
DV.M1_NE_LoboDrop = { 8, 12, 16 }
DV.M1_NE_MMLs = { 3, 5, 8 }

DV.M1_NE_Janus = { 3, 7, 10 }
DV.M1_NE_Gunships = { 5, 10, 15 }



function NEBase()
    neBase:InitializeDifficultyTables(Oxygen.Brains.UEF, "M1_NE_Base", "M1_NE_Base_M", 100,
        {
            ["M1_NE_Base"] = 1000,
        }
    )
    neBase:StartNonZeroBase { DV.M1_NE_EngineersCount, DV.M1_NE_AssistersCount }
    neBase:SetActive('AirScouting', true)
    neBase:SetBuildAllStructures(true)

    neBase:SetBuildTransports(true)
    neBase:SetTransportsTech(2)
    neBase.TransportsNeeded = 3
    do -- land
        ---@type PlatoonTemplateBuilder
        local pb = PlatoonBuilder()

        pb
            :UseAIFunction(Oxygen.PlatoonAI.Common, "PatrolChainPickerThread")
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
                :AddUnit(UNIT "Lobo", DV.M1_NE_LoboDrop,"Artillery")
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
                :AddUnit(UNIT "Parashield", DV.M1_NE_Shield, 'Artillery')
                :AddCondition(BC.HumansCategoryCondition(categories.DEFENSE, ">=", 10))
                :Create(Oxygen.Platoons.TargettingPriorities
                    {
                        categories.ANTIMISSILE * categories.TECH2,
                        categories.DEFENSE * categories.STRUCTURE * categories.DIRECTFIRE
                    }
                )


        }
    end
    do --air
        ---@type PlatoonTemplateBuilder
        local pb = PlatoonBuilder()

        pb
            :UseAIFunction(Oxygen.PlatoonAI.Common, "PatrolChainPickerThread")
            :UseType "Air"
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
            pb:New "NE Janus attack"
                :Priority(1000)
                :AddUnit(PARSE "CombatFighter", DV.M1_NE_Janus, 'Attack', "GrowthFormation")
                :AIFunction(SPAIFileName, 'CategoryHunterPlatoonAI')
                :Data
                {
                    CategoryList = {
                        categories.DEFENSE * categories.DIRECTFIRE * categories.STRUCTURE,
                        categories.STRUCTURE * categories.SHIELD,
                    }
                }
                :AddCondition(BC.HumansEconomyCondition("AvgMassIncome", ">=", 250))
                :Create(),

            pb:New "NE gunships attack"
                :Priority(750)
                :AddUnit(PARSE "Gunship", DV.M1_NE_Gunships, 'Attack', "GrowthFormation")
                :AIFunction(SPAIFileName, 'CategoryHunterPlatoonAI')
                :Data
                {
                    CategoryList = {
                        categories.ANTIAIR * categories.STRUCTURE,
                        categories.ENERGYPRODUCTION,
                        categories.ENGINEER,
                    }
                }
                :AddCondition(BC.HumansEconomyCondition("AvgMassIncome", ">=", 150))
                :AddCondition(BC.HumansCategoryCondition(categories.ANTIAIR, "<", 10))
                :Create(),
        }

    end
end

DV.M1_SW_EngineerCount = { 4, 7, 10 }
DV.M1_SW_AssisterCount = { 2, 4, 6 }

DV.M1_SW_JanusCount = { 2, 4, 6 }
DV.M1_SW_Gunships = { 2, 4, 6 }
DV.M1_SW_Bombers = { 2, 4, 6 }

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


    do --land platoons

        ---@type PlatoonTemplateBuilder
        local pb = PlatoonBuilder()

        pb
            :UseAIFunction(Oxygen.PlatoonAI.Common, "PatrolChainPickerThread")
            :UseType "Land"
            :UseData
            {
                PatrolChains = {
                    "M1_LAC2",
                    "M1_LAC1",
                }
            }


        swBase:LoadPlatoons
        {
            pb:New "SW Pillar attack"
                :Priority(200)
                :InstanceCount(4)
                :AddUnit(UNIT "Pillar", DV.M1_NE_Pillars)
                :AddUnit(UNIT "Parashield", DV.M1_NE_Shield)
                :AddUnit(UNIT "T2 UEF Flak", DV.M1_NE_Flak)
                :Create(),


            pb:New "ArtyDrop SW"
                :Priority(100)
                :AddUnit(UNIT "Lobo", DV.M1_NE_LoboDrop)
                :AIFunction('/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports')
                :Data
                {
                    TransportReturn = "M1_SW_Base_M",
                    TransportChain = "M1_LTC1",
                    LandingChain = "M1_LLC1",
                    AttackChain = "Spawn_AC"
                }
                :Create(),

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
                    "M1_AAC1",
                    "M1_LAC2",
                    "M1_LAC1",
                },
                Offset = 30
            }


        swBase:LoadPlatoons
        {
            pb:New "SW T1 bomber attack"
                :AddUnit(UNIT "T1 UEF Bomber", DV.M1_SW_Bombers)
                :Priority(200)
                :InstanceCount(4)
                :AIFunction(SPAIFileName, 'CategoryHunterPlatoonAI')
                :Data
                {
                    CategoryList = {
                        categories.ENGINEER * categories.TECH1,
                        categories.ENGINEER * categories.TECH2,
                        categories.ENGINEER * categories.TECH3
                    }
                }
                :Create(),

            pb:New "SW Gunship attack"
                :AddUnit(UNIT "T2 UEF Gunship", DV.M1_SW_Gunships)
                :Priority(100)
                :InstanceCount(2)
                :Create(),


            pb:New "SW Janus attacks"
                :Priority(1000)
                :InstanceCount(2)
                :Difficulty { "Hard", "Medium" }
                :AddUnit(PARSE "CombatFighter", DV.M1_SW_JanusCount, 'Attack', "GrowthFormation")
                :AddCondition(BC.HumansEconomyCondition("EnergyIncome", ">", 5000))
                :AIFunction(SPAIFileName, 'CategoryHunterPlatoonAI')
                :Data
                {
                    CategoryList = {
                        categories.ENERGYPRODUCTION,
                        categories.MASSEXTRACTION + categories.MASSFABRICATION,
                        categories.ENGINEER
                    }
                }
                :Create(),
        }
    end

end

DV.M1_SE_EngineerCount = { 10, 20, 30 }
DV.M1_SE_AssisterCount = { 7, 15, 20 }




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

    seBase:LoadPlatoonsFromFile()


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
                BC.HumansCategoryCondition(categories.LAND * categories.MOBILE, ">=", 30),
                BC.HumansBuiltOrActiveCategoryCondition(categories.EXPERIMENTAL * categories.LAND, ">", 0)
            }
        })
    end


    seBase:AddUnitAI("M1_Fatboy",
        {
            PlatoonAIFunction = { Oxygen.PlatoonAI.Common, "PatrolChainPickerThread" },
            PlatoonData = {
                PatrolChains = {
                    "M1_LAC3",
                    "M1_LAC6",
                },
            },
            Priority = 2500,
            Amount = DV.M1_SE_FatboyAmout,
            KeepAlive = true,
            Retry = true,
            MaxAssist = DV.M1_SE_FatboyAssist,
            BuildCondition =
            {
                BC.HumansCategoryCondition(categories.DEFENSE * categories.DIRECTFIRE, ">=", 10),
                BC.HumansCategoryCondition(categories.SHIELD * categories.STRUCTURE, ">=", 5),
                BC.HumansEconomyCondition("AvgMassIncome", ">=", 200),
            }
        })
end

function Main()

    Oxygen.Game.Armies.CreateGroup("UEF", 'M1_SW_Power', true)

    tauntUEF:AddPlayerIntelCategoryTaunt("M1_UEF_Locate_Taunt", Oxygen.Brains.UEF, categories.ALLUNITS)

    NEBase()
    SWBase()
    SEBase()
    NukeBase()
end
