local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local AIBuildStructures = import('/lua/ai/aibuildstructures.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Utilities = import('/lua/Utilities.lua')
local Cinematics = import('/lua/cinematics.lua')
local TauntManager = import('/lua/TauntManager.lua')
local Buff = import('/lua/sim/Buff.lua')
local AC = Oxygen.Cinematics
local Game = Oxygen.Game
local RequireIn = Oxygen.RequireIn
---@type DoNotKillObjective
local DoNotKill = import(Oxygen.ScenarioFolder "DoNotKill.lua").DoNotKillObjective

local objectiveBuilder = Oxygen.ObjectiveBuilder()
local playersManager = Oxygen.PlayersManager()
local objectives = Oxygen.ObjectiveManager()
local Brains = Oxygen.Brains
local DV = Oxygen.DifficultyValues
---@type GWStrings
local voStrings = import(Oxygen.ScenarioFolder "VOStrings.lua").lines

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

                AC.DisplayText(
                    [[Mission made by 4z0t
                    Credits: 
                        - Tron- (he didnt make a map but wanted to)
                        - Zasport (measured how many mexes he could make before death)
                        - Razarem (is in Jail)
                        - Sladow-Noob (complaining about strats killing mexes)]],
                    24,
                    "ffffffff",
                    "leftcenter",
                    10
                )

            end)

            ---@type PlayerUnitIntelTrigger
            objectives.Data.M1_UEF_IntelTrigger = Oxygen.Triggers.PlayerUnitIntelTrigger(
                function(unit)
                    ScenarioFramework.Dialogue(voStrings.M1_ACU_Locate, nil, true)
                    objectives:Start "M1_DoNotKill"
                end
            )
            objectives.Data.M1_UEF_IntelTrigger:Add(ScenarioInfo.UEFacu)

            ---@type PlayerCategoryIntelTrigger
            objectives.Data.M1_Nuke_IntelTrigger = Oxygen.Triggers.PlayerCategoryIntelTrigger(
                function(unit)
                    objectives:Start "M1_kill_nuke"
                end
            )
            objectives.Data.M1_Nuke_IntelTrigger:Add(categories.NUKE * categories.STRUCTURE, Oxygen.Brains.UEF)

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

            --objectives:EndGame(false)
            WaitSeconds(5)

            ---@type UnitsController
            local unitsController = Oxygen.UnitsController()
            unitsController
                :FromArmyUnits(Brains.UEF, categories.ALLUNITS)
                :ImmediatelyKill()
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
            local doNotKillObjective = objectives:Get("M1_DoNotKill")
            if not doNotKillObjective.Active and not doNotKillObjective.Complete then
                LOG("UEF commander was killed")
                return
            end
            Game.Armies.SetPlayersAlliance(Brains.UEF:GetArmyIndex(), "Ally")
            doNotKillObjective:Success()

            ScenarioFramework.FakeTeleportUnit(ScenarioInfo.UEFacu, true)

            Game.Armies.TransferUnitsToArmy(Brains.UEF, Brains.MainPlayer, categories.ALLUNITS)

            WaitSeconds(5)
            objectives:EndGame(true)
        end)
        :Create(),

    objectiveBuilder
        :NewSecondary "M1_kill_nuke"
        :Title "Kill nuke before it launches"
        :Description [[Kill the nuke on South-west of the area
        ]]
        :To(Oxygen.Objective.Kill)
        :Target
        {
            MarkUnits = true
        }
        :OnStart(function()
            LOG("NUKE LOCATED")
            local nukes = Brains.UEF:GetListOfUnits(categories.NUKE * categories.STRUCTURE, false)
            return {
                Units = nukes,
            }
        end)
        :OnSuccess(function()
            LOG("NUKE KILLED")
        end)
        :Create(),




}


function OnPopulate()
    LOG "INITIALIZING ARMIES"

    Game.Armies.Initialize()

    LOG "SETTING UP PLAYERS"

    local playersData = playersManager:Init
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

    local playersCount = table.getsize(playersData)

    local buffDef = Buffs['CheatIncome']
    local buffAffects = buffDef.Affects
    buffAffects.EnergyProduction.Mult = ({ 1.1, 1.2, 1.3, 1.4, 1.5 })[playersCount]
    buffAffects.MassProduction.Mult = ({ 1.5, 1.75, 2, 2.25, 2.5 })[playersCount]

    LOG(("MASS income cheat buff %.2f"):format(buffAffects.MassProduction.Mult))
    LOG(("ENERGY income cheat buff %.2f"):format(buffAffects.EnergyProduction.Mult))
end

function OnStart(self)
    LOG "STARTING SCENARIO"

    Brains.MainPlayer = ArmyBrains[1]
    Brains.UEF = ArmyBrains[2]
    Brains.Cybran = ArmyBrains[3]
    Brains.Aeon = ArmyBrains[4]
    Brains.Sera = ArmyBrains[5]
    Brains.Unknown = ArmyBrains[6]

    Game.SetPlayableArea('M1', false)

    import(Oxygen.ScenarioFolder "M1_UEF_Bases.lua").Main()
    for _, unit in Brains.UEF:GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
        Buff.ApplyBuff(unit, 'CheatIncome')
    end
    objectives:Start "M1_locate"
end
