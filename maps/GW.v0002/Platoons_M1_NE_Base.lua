local PlatoonBuilder = Oxygen.PlatoonBuilder
local UNIT = Oxygen.UnitNames.Get
local BC = Oxygen.BuildConditions
local PARSE = Oxygen.UnitNames.FactionParse.FactionUnitParser("UEF")

local DV = Oxygen.DifficultyValues
local SPAIFileName = '/lua/scenarioplatoonai.lua'

DV.M1_NE_Pillars = { 4, 5, 6 }
DV.M1_NE_Flak = { 0, 1, 2 }
DV.M1_NE_Shield = { 1, 2, 3 }
DV.M1_NE_LoboDrop = { 8, 12, 16 }
DV.M1_NE_MMLs = { 3, 5, 8 }

DV.M1_NE_Janus = { 3, 7, 10 }
DV.M1_NE_Gunships = { 5, 10, 15 }


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
                "M1_LAC7",
                "M1_LAC5",
                "M1_LAC4",
            }
        }

    baseManager:LoadPlatoons
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
            :AddUnit(UNIT "Lobo", DV.M1_NE_LoboDrop, "Artillery")
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
            :Create(Oxygen.Platoons.TargettingPriorities {
                categories.ANTIMISSILE * categories.TECH2,
                categories.DEFENSE * categories.STRUCTURE * categories.DIRECTFIRE
            })
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
                "M1_LAC7",
                "M1_LAC5",
                "M1_LAC4",
            }
        }

    baseManager:LoadPlatoons
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

---@param baseManager AdvancedBaseManager
function Naval(baseManager)

end
