local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local TauntManager = import('/lua/TauntManager.lua')
local PlatoonBuilder = Oxygen.PlatoonBuilder
local UNIT = Oxygen.UnitNames.Get
local BC = Oxygen.BuildConditions
local BaseManager = Oxygen.BaseManager.BaseManagers.AdvancedBaseManager

local PARSE = Oxygen.UnitNames.FactionParse.FactionUnitParser("UEF")

local SPAIFileName = '/lua/scenarioplatoonai.lua'


local tauntUEF = TauntManager.CreateTauntManager("UEF", Oxygen.ScenarioFolder "VOStrings.lua")

---@type AdvancedBaseManager
local neBase = BaseManager()
---@type AdvancedBaseManager
local swBase = BaseManager()
---@type AdvancedBaseManager
local seBase = BaseManager()

---@type NukeBaseManger
local nukeBase = Oxygen.BaseManager.BaseManagers.NukeBaseManger()


local DV = Oxygen.DifficultyValues

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


DV.M1_SE_Titans = { 3, 4, 5 }
DV.M1_SE_Bombers = { 3, 4, 5 }
DV.M1_SE_Gunships = { 3, 4, 5 }

DV.M1_SE_BuildAirDefenses = { false, false, true }
DV.M1_SE_BuildLandDefenses = { false, false, true }

DV.M1_SE_PercivalCount = { 1, 2, 4 }
DV.M1_SE_PercivalShieldsCount = { 1, 3, 6 }
DV.M1_SE_HugePercivalCount = { 1, 6, 10 }
DV.M1_SE_HugePercivalShieldsCount = { 1, 6, 10 }

DV.M1_SE_HeavyGunships = { 3, 5, 10 }
DV.M1_SE_HeavyGunshipsSupportASFs = { 0, 10, 15 }
DV.M1_SE_ASFs = { 0, 20, 30 }
DV.M1_SE_Strats = { 2, 5, 8 }
DV.M1_SE_StratsHuge = { 2, 11, 15 }

DV.M1_SE_FatboyAssist = { 2, 4, 7 }
DV.M1_SE_FatboyAmout = { 1, 2, 3 }


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
            :UseAIFunction(Oxygen.PlatoonAI.Common, "PatrolChainPickerThread")
            :UseType "Land"
            :UseData
            {
                PatrolChains = {
                    "M1_LAC3",
                    "M1_LAC6",
                },
                Offset = 30
            }


        seBase:LoadPlatoons
        {
            pb:New "SE Titan attack"
                :AddUnit(UNIT "Titan", DV.M1_SE_Titans)
                :Priority(200)
                :InstanceCount(4)
                :Create(),

            pb:New "NE Engineers"
                :InstanceCount(1)
                :Priority(700)
                :Difficulty "Hard"
                :Type "Any"
                :AddUnit(UNIT "T3 UEF Engineer", 5)
                :Data
                {
                    UseTransports = true,
                    TransportReturn = "M1_SE_Base_M",
                    TransportChain = "M1_TLC5",
                    LandingLocation = "M1_NE_Base_M",
                }
                :Create(Oxygen.BaseManager.Platoons.ExpansionOf "M1_NE_Base"),

            pb:New "SW Engineers"
                :InstanceCount(1)
                :Priority(700)
                :Type "Any"
                :Difficulty "Hard"
                :AddUnit(UNIT "T3 UEF Engineer", 5)
                :Data
                {
                    UseTransports = true,
                    TransportReturn = "M1_SE_Base_M",
                    TransportChain = "M1_TLC4",
                    LandingLocation = "M1_SW_Base_M",
                }
                :Create(Oxygen.BaseManager.Platoons.ExpansionOf "M1_SW_Base"),

            pb:New "Nuke base Engineers"
                :InstanceCount(1)
                :Priority(1000)
                :Type "Any"
                :Difficulty "Hard"
                :AddUnit(UNIT "T3 UEF Engineer", 5)
                :Data
                {
                    UseTransports = true,
                    TransportReturn = "M1_SE_Base_M",
                    TransportChain = "M1_NukeBase_Transport",
                    LandingLocation = "M1_Nuke_Base_M",
                }
                :Create(Oxygen.BaseManager.Platoons.ExpansionOf "M1_Nuke_Base"),

            pb:New "SE Percy attack"
                :Priority(1000)
                :InstanceCount(2)
                :Difficulty { "Hard", "Medium" }
                :AddUnit(UNIT "Percival", DV.M1_SE_PercivalCount)
                :AddUnit(UNIT "Parashield", DV.M1_SE_PercivalShieldsCount)
                :AddCondition(BC.HumansEconomyCondition("MassIncome", ">=", 200))
                :Create(Oxygen.Platoons.TargettingPriorities {
                    categories.MASSFABRICATION - categories.COMMAND, -- target all that makes mass from nothing, but ACU
                    categories.MASSEXTRACTION,
                    categories.ENERGYPRODUCTION
                }),

            pb:New "SE Huge Percy attack"
                :Priority(1500)
                :InstanceCount(2)
                :Difficulty { "Hard", "Medium" }
                :AddUnit(UNIT "Percival", DV.M1_SE_HugePercivalCount)
                :AddUnit(UNIT "Parashield", DV.M1_SE_HugePercivalShieldsCount)
                :AddCondition(BC.HumansEconomyCondition("MassIncome", ">=", 300))
                :Create(Oxygen.Platoons.TargettingPriorities {
                    categories.MASSFABRICATION - categories.COMMAND, -- target all that makes mass from nothing, but ACU
                    categories.MASSEXTRACTION,
                    categories.ENERGYPRODUCTION
                }),
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

            pb:New "SE ASFs"
                :Priority(1000)
                :InstanceCount(2)
                :Difficulty { "Hard", "Medium" }
                :AddUnit(PARSE "AirSuperiority", DV.M1_SE_ASFs, 'Attack', "GrowthFormation")
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
                :AddUnit(PARSE "StratBomber", DV.M1_SE_Strats, 'Attack', "GrowthFormation")
                :AddCondition(BC.HumansEconomyCondition("AvgMassIncome", ">=", 200))
                :AIFunction(SPAIFileName, 'CategoryHunterPlatoonAI')
                :Data
                {
                    CategoryList =
                    {
                        categories.MASSFABRICATION - categories.COMMAND, -- target all that makes mass from nothing, but ACU
                        categories.MASSEXTRACTION,
                        categories.ENERGYPRODUCTION
                    }
                }
                :Create(),

            pb:New "SE Heavy gunships"
                :Priority(2000)
                :InstanceCount(1)
                :Difficulty { "Hard", "Medium" }
                :AddUnit(PARSE "HeavyGunship", DV.M1_SE_HeavyGunships, "Attack", "GrowthFormation")
                :AddUnit(PARSE "AirSuperiority", DV.M1_SE_HeavyGunshipsSupportASFs, 'Support', "GrowthFormation")
                :AddCondition(BC.HumansEconomyCondition("AvgMassIncome", ">=", 250))
                :AIFunction(SPAIFileName, 'CategoryHunterPlatoonAI')
                :Data
                {
                    CategoryList =
                    {
                        (categories.DEFENSE + categories.MOBILE) * categories.ANTIAIR,
                        categories.SHIELD * categories.STRUCTURE,
                        categories.MASSFABRICATION - categories.COMMAND,
                        categories.MASSEXTRACTION,
                        categories.ENERGYPRODUCTION
                    }
                }
                :Create(),

            pb:New "SE Strats huge"
                :Priority(2000)
                :InstanceCount(1)
                :AddUnit(PARSE "StratBomber", DV.M1_SE_Strats, 'Attack', "GrowthFormation")
                :AddCondition(BC.HumansEconomyCondition("AvgMassIncome", ">=", 400))
                :AIFunction(SPAIFileName, 'CategoryHunterPlatoonAI')
                :Data
                {
                    CategoryList =
                    {
                        categories.MASSFABRICATION, -- target all that makes mass from nothing, but ACU
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


    seBase:AddUnitAI("M1_Fatboy",
        {
            PlatoonAIFunction = { Oxygen.PlatoonAI.Common, "PatrolChainPickerThread" },
            PlatoonData = {
                PatrolChains = {
                    "M1_LAC3",
                    "M1_LAC6",
                },
            },
            Priority = 2000,
            Amount = DV.M1_SE_FatboyAmout,
            KeepAlive = true,
            Retry = true,
            MaxAssist = DV.M1_SE_FatboyAssist,
            BuildCondition =
            {
                BC.HumansCategoryCondition(categories.DEFENSE * categories.DIRECTFIRE, ">=", 10),
                BC.HumansCategoryCondition(categories.SHIELD * categories.STRUCTURE, ">=", 5),
                BC.HumansEconomyCondition("AvgMassIncome", ">=", 200)
            }
        })
end

function Main()

    Oxygen.Game.Armies.CreateArmyGroup("UEF", 'M1_SW_Power', true)

    tauntUEF:AddPlayerIntelCategoryTaunt("M1_UEF_Locate_Taunt", Oxygen.Brains.UEF, categories.ALLUNITS)

    NEBase()
    SWBase()
    SEBase()
    NukeBase()
end
