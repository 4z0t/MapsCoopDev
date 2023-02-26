local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
---@type string
local MAP_FOLDER = ScenarioInfo.save:gsub("[^/]*%.lua$", "")
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



--local VOStrings = import("/maps/GW/VOStrings.lua").lines
local objectiveBuilder = Oxygen.ObjectiveBuilder()
local playersManager = Oxygen.PlayersManager()


local objectives = Oxygen.ObjectiveManager()

function OnPopulate()
    Game.Armies.Initialize()



end

function OnStart(self)



end
