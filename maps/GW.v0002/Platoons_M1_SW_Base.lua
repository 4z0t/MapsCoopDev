local PlatoonBuilder = Oxygen.PlatoonBuilder
local UNIT = Oxygen.UnitNames.Get
local BC = Oxygen.BuildConditions
local PARSE = Oxygen.UnitNames.FactionParse.FactionUnitParser("UEF")

local DV = Oxygen.DifficultyValues
local SPAIFileName = '/lua/scenarioplatoonai.lua'

DV.M1_SW_Pillars = { 4, 5, 6 }
DV.M1_SW_Flak = { 0, 1, 2 }
DV.M1_SW_Shield = { 1, 2, 3 }
DV.M1_SW_LoboDrop = { 8, 12, 16 }
DV.M1_SW_MMLs = { 3, 5, 8 }


DV.M1_SW_JanusCount = { 2, 4, 6 }
DV.M1_SW_Gunships = { 2, 4, 6 }
DV.M1_SW_Bombers = { 2, 4, 6 }


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
                "M1_LAC2",
                "M1_LAC1",
            }
        }


    baseManager:LoadPlatoons
    {
        pb:New "SW Pillar attack"
            :Priority(200)
            :InstanceCount(4)
            :AddUnit(UNIT "Pillar", DV.M1_SW_Pillars)
            :AddUnit(UNIT "Parashield", DV.M1_SW_Shield)
            :AddUnit(UNIT "T2 UEF Flak", DV.M1_SW_Flak)
            :Create(),


        pb:New "ArtyDrop SW"
            :Priority(100)
            :AddUnit(UNIT "Lobo", DV.M1_SW_LoboDrop)
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
                "M1_AAC1",
                "M1_LAC2",
                "M1_LAC1",
            },
            Offset = 30
        }


    baseManager:LoadPlatoons
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

---@param baseManager AdvancedBaseManager
function Naval(baseManager)

end
