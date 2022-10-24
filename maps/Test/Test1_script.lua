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

local VOStrings = import("/maps/Test/VOStrings.lua").lines
local objectiveBuilder = import("/lua/ASF/ObjectiveBuilder.lua").ObjectiveBuilder()
local playersManager = import("/lua/ASF/PlayersManager.lua").PlayersManager()


ScenarioInfo.TheWheelie = 2

function DeathResult(unit)
	LOG("Punch lox")
end

local objectives = ObjectiveManager()
objectives:Init
{
	objectiveBuilder
		:New "start"
		:Title "TEST"
		:Description "Test"
		:To "timer"
		:Target
		{
			ShowProgress = true,
			Timer = 60,
			ExpireResult = 'complete',
		}
		:OnStart(function()
			Cinematics.NISMode(
				function()
					Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker("Cam1"), 0)
					ScenarioFramework.Dialogue(VOStrings.Start, nil, true)
					WaitSeconds(1)
					Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker("Cam2"), 3)
					ScenarioFramework.KillBaseInArea(ArmyBrains[ScenarioInfo.TheWheelie], 'StartArea')
					WaitSeconds(2)
					playersManager:Spawn(DeathResult)
					Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker("Cam3"), 3)
				end
			)
		end)
		:OnSuccess(function()

		end)
		:Create()
}


function OnPopulate()
	ScenarioUtils.InitializeScenarioArmies()

	playersManager:Init
	{
		{
			color = "ff0000ff",
			units =
			{
				Cybran = 'CybranPlayer_1',
				UEF = 'UEFPlayer_1',
				Aeon = 'AeonPlayer_1',
			},
			enhancements = {
				Cybran = { "AdvancedEngineering", "T3Engineering", "ResourceAllocation" },
				UEF = { "AdvancedEngineering", "T3Engineering", "ResourceAllocation" },
				Aeon = { "AdvancedEngineering", "T3Engineering", "ResourceAllocation" },
			}
		},
		{
			color = "ffffff00",
			units =
			{
				Cybran = 'CybranPlayer_2',
				UEF = 'UEFPlayer_2',
				Aeon = 'AeonPlayer_2',
			},
			enhancements = {
				Cybran = { "AdvancedEngineering", "T3Engineering", "ResourceAllocation" },
				UEF = { "AdvancedEngineering", "T3Engineering", "ResourceAllocation" },
				Aeon = { "AdvancedEngineering", "T3Engineering", "ResourceAllocation" },
			}
		},
	}

	ScenarioUtils.CreateArmyGroup('TheWheelie', 'P1Qbase1')
	ScenarioUtils.CreateArmyGroup('TheWheelie', 'P1Qbase2')
	ScenarioUtils.CreateArmyGroup('TheWheelie', 'P1QOuterEco')
end

function OnStart(self)
	ScenarioFramework.SetPlayableArea('StartArea', false)
	objectives:Start("start")
end
