local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local AIBuildStructures = import('/lua/ai/aibuildstructures.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Utilities = import('/lua/Utilities.lua')
local Cinematics = import('/lua/cinematics.lua')
local Buff = import('/lua/sim/Buff.lua')
local TauntManager = import('/lua/TauntManager.lua')
local AC = Oxygen.Cinematics
local Game = Oxygen.Game
local RequireIn = Oxygen.RequireIn
local DV = Oxygen.DifficultyValues

---@type GWStrings
local voStrings = import(Oxygen.ScenarioFolder "VOStrings.lua").lines
---@type DoNotKillObjective
local DoNotKill = import(Oxygen.ScenarioFolder "DoNotKill.lua").DoNotKillObjective

local objectiveBuilder = Oxygen.ObjectiveBuilder()
local playersManager = Oxygen.PlayersManager()
local objectives = Oxygen.ObjectiveManager()


DV.M1_ACU_ShakeAmount = { 0.2, 0.4, 0.7 }

objectives.Data = {}


local deadCounter = 0
---@param unit Unit
local function PlayerDeath(unit)
    deadCounter = deadCounter + 1
    if ScenarioInfo.Options.ACUDeathType == 2 or deadCounter >= table.getsize(ScenarioInfo.HumanPlayers) then
        objectives:EndGame(false)
    end
end

objectives:Init
{
    objectiveBuilder
        :New "M1_locate"
        :Title "Scout out the area"
        :Description [[Three commanders were lost on this planet during scout mission.
                    Find out what happend and if they are alive, save them.]]
        :To(Oxygen.Objective.Locate)
        :OnStart(function()

            AC.NISMode(function()
                AC.MoveTo("Cam0", 0)
                ScenarioFramework.Dialogue(voStrings.M1_Start, nil, true)
                AC.MoveTo("Cam1", 3)
                playersManager:WarpIn(PlayerDeath)
            end)

            ---@type PlayerIntelTrigger
            objectives.Data.M1_UEF_IntelTrigger = Oxygen.Triggers.PlayerIntelTrigger(
                function(unit)
                    ScenarioFramework.Dialogue(voStrings.M1_ACU_Locate, nil, true)
                    objectives:Start "M1_DoNotKill"
                end
            )
            objectives.Data.M1_UEF_IntelTrigger:Add(ScenarioInfo.UEFacu)


            local unit = Game.Armies.CreateUnit('Unknown', 'M1_MindController')
            objectives.Data.M1_MindController = unit
            unit:SetDoNotTarget(true)
            unit.CanTakeDamage = false
            unit.CanBeKilled = false
            unit:SetReclaimable(false)
            --ScenarioFramework.Dialogue(VOStrings.Save, nil, true)
            ---@type ObjectiveTarget
            return {
                Units = { objectives.Data.M1_MindController },
            }
        end)
        :Next "M1_capture"
        :Create(),

    objectiveBuilder
        :New "M1_capture"
        :Title "Capture unknown structure"
        :Description [[We need to know what this structure does.
        Capture it, so, we can examine it.
        ]]
        :To(Oxygen.Objective.Capture)
        :Target
        {
            MarkUnits = true
        }
        :OnStart(function()
            ScenarioFramework.Dialogue(voStrings.M1_Capture, nil, true)

            return {
                Units = { objectives.Data.M1_MindController },
            }
        end)
        :Next "M1_damage"
        :Create(),

    objectiveBuilder
        :New "M1_DoNotKill"
        :Title "Do not kill the commander"
        :Description ""
        :To(DoNotKill)
        :Target
        {
            Hidden = true
        }
        :OnStart(function()
            return {
                Units = { ScenarioInfo.UEFacu },
            }
        end)
        :OnFail(function()
            ScenarioFramework.Dialogue(voStrings.M1_Kill, nil, true)

            objectives:EndGame(false)
        end)
        :Create(),

    objectiveBuilder
        :New "M1_damage"
        :Title "Shake up the commander"
        :Description [[Damage the commander enough but do not kill him!
        ]]
        :To(Oxygen.Objective.Damage)
        :Target
        {
            Amount = DV.M1_ACU_ShakeAmount
        }
        :OnStart(function()

            ScenarioFramework.Dialogue(voStrings.M1_Damage, nil, true)

            return {
                Units = { ScenarioInfo.UEFacu },
            }
        end)
        :OnSuccess(function()
            LOG("SUCCESS DAMAGE")
            WaitSeconds(10)

            objectives:Get("M1_DoNotKill"):Success()
            objectives:EndGame(true)
        end)
        :Create()




}


function OnPopulate()
    LOG "INITIALIZING ARMIES"

    Game.Armies.Initialize()

    LOG "SETTING UP PLAYERS"

    playersManager:Init
    {
        enhancements = {
            UEF = { "ResourceAllocation", "AdvancedEngineering", "T3Engineering" },
            Cybran = { "ResourceAllocation", "AdvancedEngineering", "T3Engineering" },
            Aeon = { "ResourceAllocation", "AdvancedEngineering", "T3Engineering" },
        },
        {
            units = {
                UEF = "UEF1",
                Cybran = "Cybran1",
                Aeon = "Aeon1",
            },
            color = "00A2FF"
        },
        {
            units = {
                UEF = "UEF2",
                Cybran = "Cybran2",
                Aeon = "Aeon2",
            },
            color = "113D00"
        },
        {
            units = {
                UEF = "UEF3",
                Cybran = "Cybran3",
                Aeon = "Aeon3",
            },
            color = "DF0000"
        },
        {
            units = {
                UEF = "UEF4",
                Cybran = "Cybran4",
                Aeon = "Aeon4",
            },
            color = "8835CC"
        },
        {
            units = {
                UEF = "UEF5",
                Cybran = "Cybran5",
                Aeon = "Aeon5",
            },
            color = "55D4B9"
        },

    }

    Game.Armies.SetSharedUnitCap(4000)
    Game.Armies.SetUnitCap("UEF", 4000)
    Game.Armies.SetUnitCap("Cybran", 4000)
    Game.Armies.SetUnitCap("Aeon", 4000)
    Game.Armies.SetUnitCap("Unknown", 4000)
    Game.Armies.SetUnitCap("Sera", 4000)
    Game.Armies.SetColor("UEF", "2C2FE0")
    Game.Armies.SetColor("Cybran", "680000")
    Game.Armies.SetColor("Aeon", "6ED346")
    Game.Armies.SetColor("Unknown", "E68200")
    Game.Armies.SetColor("Sera", "E68200")
end

local Brains = Oxygen.Brains

function OnStart(self)
    LOG "STARTING SCENARIO"

    Brains.UEF = ArmyBrains[2]
    Brains.Cybran = ArmyBrains[3]
    Brains.Aeon = ArmyBrains[4]
    Brains.Sera = ArmyBrains[5]
    Brains.Unknown = ArmyBrains[6]

    Game.SetPlayableArea('M1', false)

    import(Oxygen.ScenarioFolder "M1_UEF_Bases.lua").Main()

    objectives:Start "M1_locate"
end
