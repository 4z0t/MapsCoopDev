local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local ObjectiveManager = import("/lua/ASF/ObjectiveManager.lua").ObjectiveManager
local Objectives = import('/lua/ScenarioFramework.lua').Objectives
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local AIBuildStructures = import('/lua/ai/aibuildstructures.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Utilities = import('/lua/Utilities.lua')
local Cinematics = import('/lua/cinematics.lua')
local Buff = import('/lua/sim/Buff.lua')
local TauntManager = import('/lua/TauntManager.lua')

function OnPopulate()
	ScenarioUtils.InitializeArmies()
end

function OnStart(self)
	ScenarioFramework.SetPlayableArea('StartArea', false)

end
