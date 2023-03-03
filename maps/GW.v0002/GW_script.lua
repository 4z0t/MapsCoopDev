local MAP_FOLDER = Oxygen.ScenarioFolder()
LOG(MAP_FOLDER)

local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local AIBuildStructures = import('/lua/ai/aibuildstructures.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Utilities = import('/lua/Utilities.lua')
local Cinematics = import('/lua/cinematics.lua')
local Buff = import('/lua/sim/Buff.lua')
local TauntManager = import('/lua/TauntManager.lua')
local Objectives = import('/lua/ScenarioFramework.lua').Objectives
local AC = Oxygen.Cinematics
local Game = Oxygen.Game
local RequireIn = Oxygen.RequireIn
local DifficultyValue = Oxygen.DifficultyValue
local DV = DifficultyValue.Get



--local VOStrings = import(Oxygen.MapFolder "VOStrings.lua").lines
local objectiveBuilder = Oxygen.ObjectiveBuilder()
local playersManager = Oxygen.PlayersManager()


local objectives = Oxygen.ObjectiveManager()

objectives.Data = {}

objectives:Init
{
    objectiveBuilder
        :New "M1_locate"
        :Title "Scout out the area"
        :Description ""
        :To "locate"
        :OnStart(function()

            AC.NISMode(function()
                AC.MoveTo("Cam0", 0)
                AC.MoveTo("Cam1", 3)
                playersManager:WarpIn()
            end)

            local unit = ScenarioUtils.CreateArmyUnit('Unknown', 'M1_MindController')
            objectives.Data.M1_MindController = unit
            unit:SetDoNotTarget(true)
            unit:SetCanTakeDamage(false)
            unit:SetCanBeKilled(false)
            unit:SetReclaimable(false)
            --ScenarioFramework.Dialogue(VOStrings.Save, nil, true)
            ---@type ObjectiveTarget
            return {
                Units = { objectives.Data.M1_MindController },
            }
        end)
        :OnSuccess(function()
            LOG("ABOBA")
        end)
        :Next "M1_capture"
        :Create(),

    objectiveBuilder
        :New "M1_capture"
        :Title "Capture unknown structure"
        :Description ""
        :To "capture"
        :Target {
            MarkUnits = true
        }
        :OnStart(function()
            return {
                Units = { objectives.Data.M1_MindController },
            }
        end)
        :OnSuccess(function()
            LOG("ABOBA")
        end)
        :Create()




}


function OnPopulate()

    LOG "INITIALIZING ARMIES"
    Game.Armies.Initialize()

    LOG "SETTING UP PLAYERS"

    playersManager:Init
    {
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
    Game.Armies.SetColor("UEF", "2C2FE0")
    Game.Armies.SetColor("Cybran", "680000")
    Game.Armies.SetColor("Aeon", "6ED346")
    Game.Armies.SetColor("Unknown", "E68200")




end

local Brains = Oxygen.Brains

function OnStart(self)

    LOG "STARTING SCENARIO"

    Game.SetPlayableArea('M1', false)



    Brains.UEF = ArmyBrains[2]
    Brains.Cybran = ArmyBrains[3]
    Brains.Aeon = ArmyBrains[4]
    Brains.Unknown = ArmyBrains[5]

    import(Oxygen.ScenarioFolder "M1_UEF_Bases.lua").Main()


    objectives:Start "M1_locate"


end
