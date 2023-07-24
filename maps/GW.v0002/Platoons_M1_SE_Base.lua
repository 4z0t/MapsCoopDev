local PlatoonBuilder = Oxygen.PlatoonBuilder
local UNIT = Oxygen.UnitNames.Get
local BC = Oxygen.BuildConditions
local PARSE = Oxygen.UnitNames.FactionParse.FactionUnitParser("UEF")

local DV = Oxygen.DifficultyValues
local SPAIFileName = '/lua/scenarioplatoonai.lua'


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
DV.M1_SE_ASFs_Counter_exp = { 10, 30, 50 }
DV.M1_SE_Strats = { 2, 5, 8 }
DV.M1_SE_StratsHuge = { 2, 11, 15 }

DV.M1_SE_FatboyAssist = { 2, 4, 7 }
DV.M1_SE_FatboyAmout = { 1, 2, 3 }

---@param baseManager AdvancedBaseManager
function Land(baseManager)

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
        :UseOrderPriority(true)


    baseManager:LoadPlatoons
    {
        pb:New "SE Titan attack"
            :AddUnit(UNIT "Titan", DV.M1_SE_Titans)
            :Priority(200)
            :InstanceCount(4)
            :Create(),

        pb:New "NE Engineers"
            :InstanceCount(1)
            :Difficulty "Hard"
            :Priority(700)
            :AddUnit(UNIT "T3 UEF Engineer", 5)
            :Type "Any"
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
            :AddCondition(BC.HumansEconomyCondition("AvgMassIncome", ">=", 200))
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
            :AddCondition(BC.HumansEconomyCondition("AvgMassIncome", ">=", 300))
            :Create(Oxygen.Platoons.TargettingPriorities {
                categories.MASSFABRICATION - categories.COMMAND, -- target all that makes mass from nothing, but ACU
                categories.MASSEXTRACTION,
                categories.ENERGYPRODUCTION
            }),
    }
end

---@param baseManager AdvancedBaseManager
function Air(baseManager)
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


    baseManager:LoadPlatoons
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
            :InstanceCount(1)
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
            :EnableJamming()
            :Create(),

        pb:New "SE Heavy gunships"
            :Priority(2000)
            :InstanceCount(1)
            :Difficulty { "Hard", "Medium" }
            :AddUnit(PARSE "HeavyGunship", DV.M1_SE_HeavyGunships, "Attack", "GrowthFormation")
            :AddUnit(PARSE "AirSuperiority", DV.M1_SE_HeavyGunshipsSupportASFs, 'Attack', "GrowthFormation")
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
                    categories.MASSFABRICATION,
                    categories.MASSEXTRACTION,
                    categories.ENERGYPRODUCTION
                }
            }
            :EnableJamming()
            :Create(),

        pb:New "SE ASFs counter exp"
            :Priority(2500)
            :InstanceCount(1)
            :AddUnit(PARSE "AirSuperiority", DV.M1_SE_ASFs_Counter_exp, 'Attack', "GrowthFormation")
            :AddCondition(BC.HumansBuiltOrActiveCategoryCondition(categories.AIR * categories.EXPERIMENTAL, ">", 0))
            :AIFunction(SPAIFileName, 'CategoryHunterPlatoonAI')
            :Data
            {
                CategoryList = { categories.AIR * categories.EXPERIMENTAL }
            }
            :Create(),

    }
end

---@param baseManager AdvancedBaseManager
function Naval(baseManager)

end
