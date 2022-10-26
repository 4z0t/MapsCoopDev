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
local Utils = import("/lua/ASF/Utils.lua")

local VOStrings = import("/maps/Test/VOStrings.lua").lines
local objectiveBuilder = import("/lua/ASF/ObjectiveBuilder.lua").ObjectiveBuilder()
local playersManager = import("/lua/ASF/PlayersManager.lua").PlayersManager()


ScenarioInfo.TheWheelie = 2
ScenarioInfo.Yudi = 3

function DeathResult(unit)
	LOG("Punch lox")
end

local prizoners = {
	"Razarem",
	"Accor",
	"EyelessMole",
	"Nandatum",
	"MoldPlit",
	"Bruh-",
	"Zloyvasya",
	"Oidaho",
	"Mbimra228",
	"Farizm"
}

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
					playersManager:WarpIn(DeathResult)
					Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker("Cam3"), 3)
				end
			)
			objectives:Start "prison"
		end)
		:OnSuccess(function()
			objectives:EndGame(true)
		end)
		:Create(),

	objectiveBuilder
		:NewSecondary "prison"
		:Title "Save Ban prisoners"
		:Description "Let prisoners escape"
		:To "capture"
		:OnStart(function()
			WaitSeconds(5)
			local prison = ScenarioUtils.CreateArmyUnit('Yudi', 'Prison')
			prison:SetDoNotTarget(true)
			prison:SetCanTakeDamage(false)
			prison:SetCanBeKilled(false)
			prison:SetReclaimable(false)
			prison:SetCustomName('Ban prison')
			ScenarioFramework.Dialogue(VOStrings.Save, nil, true)

			---@type ObjectiveTarget
			return {
				AlwaysVisible = true,
				Units = { prison },
			}
		end)
		:OnSuccess(function()
			ScenarioFramework.Dialogue(VOStrings.Saved, nil, true)
			local unit = ScenarioUtils.CreateArmyUnit('Player1', 'Rescued_player')
			unit:SetCustomName("Razarem")
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
				Aeon = 'AeonPlayer_1',
				Cybran = 'CybranPlayer_1',
				UEF = 'UEFPlayer_1',
				Seraphim = 'SeraPlayer_1',
			},
			enhancements = {
				Aeon = { "AdvancedEngineering", "T3Engineering", "ResourceAllocation", "ResourceAllocationAdvanced",
					"EnhancedSensors" },
				Cybran = { "AdvancedEngineering", "T3Engineering", "ResourceAllocation", "MicrowaveLaserGenerator" },
				UEF = { "AdvancedEngineering", "T3Engineering", "ResourceAllocation", "Shield", "ShieldGeneratorField" },
				Seraphim = { "AdvancedEngineering", "T3Engineering", "DamageStabilization", "DamageStabilizationAdvanced",
					"ResourceAllocation", "ResourceAllocationAdvanced" }
			},
			name = "Punch lox"
		},
		{
			color = "ffffff00",
			units =
			{
				Cybran = 'CybranPlayer_2',
				UEF = 'UEFPlayer_2',
				Aeon = 'AeonPlayer_2',
				Seraphim = 'SeraPlayer_2',
			},
			enhancements = {
				Aeon = { "AdvancedEngineering", "T3Engineering", "ResourceAllocation", "ResourceAllocationAdvanced",
					"EnhancedSensors" },
				Cybran = { "AdvancedEngineering", "T3Engineering", "ResourceAllocation", "MicrowaveLaserGenerator" },
				UEF = { "AdvancedEngineering", "T3Engineering", "ResourceAllocation", "Shield", "ShieldGeneratorField" },
				Seraphim = { "AdvancedEngineering", "T3Engineering", "DamageStabilization", "DamageStabilizationAdvanced",
					"ResourceAllocation", "ResourceAllocationAdvanced" }
			}
		},
	}

	ScenarioUtils.CreateArmyGroup('TheWheelie', 'P1Qbases')
end

function OnStart(self)
	ScenarioFramework.SetPlayableArea('StartArea', false)
	ScenarioFramework.SetArmyColor("Yudi", Utils.UnpackColor "FFDD78F1")
	ScenarioFramework.SetArmyColor("TheWheelie", Utils.UnpackColor "FF022B1B")
	objectives:Start("start")
end
