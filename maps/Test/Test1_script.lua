local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local AIBuildStructures = import('/lua/ai/aibuildstructures.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Utilities = import('/lua/Utilities.lua')
local Cinematics = import('/lua/cinematics.lua')
local Buff = import('/lua/sim/Buff.lua')
local TauntManager = import('/lua/TauntManager.lua')
local Objectives = import('/lua/ScenarioFramework.lua').Objectives
local Utils = Oxygen.Utils
local AC = Oxygen.Cinematics
local Game = Oxygen.Game

local ObjectiveManager = Oxygen.ObjectiveManager
local VOStrings = import("/maps/Test/VOStrings.lua").lines
local objectiveBuilder = Oxygen.ObjectiveBuilder()
local playersManager = Oxygen.PlayersManager()
local RequireIn = Oxygen.RequireIn

ScenarioInfo.TheWheelie = 2
ScenarioInfo.Yudi = 3

---@type table<string, AIBrain>
_G.Brains = {}

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
		:Function "CategoriesInArea"
		:To "kill"
		:Target
		{
			MarkUnits = true,
			ShowProgress = true,
			Requirements = {
				RequireIn("StartArea", categories.STRUCTURE * categories.TECH3, "==", 0, ScenarioInfo.Yudi),
				RequireIn("StartArea", categories.STRUCTURE * categories.DEFENSE - categories.WALL, "==", 0, ScenarioInfo.Yudi)
			},
		}
		:OnStart(function()
			AC.NISMode(
				function()
					UI4Sim.Callback
					{
						name = "test",
						fileName = "/maps/Test/UI/main.lua",
						functionName = "CreateUI",
						args = { 1, 2, 3 }
					}

					AC.MoveTo("Cam1", 0)
					ScenarioFramework.Dialogue(VOStrings.Start, nil, true)
					WaitSeconds(1)
					--AC.DisplayText("Global\nWarning", 120, 'ffffffff', 'center', 1)
					-- AC.MoveTo("Cam2", 3)
					-- AC.MoveTo("Cam4", 0)
					-- AC.MoveTo("Cam5", 2)
					-- AC.MoveTo("Cam6", 0)
					-- AC.MoveTo("Cam7", 2)
					ScenarioFramework.KillBaseInArea(Brains.TheWheelie, 'StartArea')
					playersManager:WarpIn(function()
						objectives:EndGame(false)
					end)
					AC.MoveTo("Cam3", 3)
					UI4Sim.Callback
					{
						name = "test",
						fileName = "/maps/Test/UI/main.lua",
						functionName = "DestroyUI",
					}
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
		:Target
		{
			AlwaysVisible = true,
		}
		:StartDelay(5)
		:OnStart(function()
			local prison = ScenarioUtils.CreateArmyUnit('Yudi', 'Prison')
			prison:SetDoNotTarget(true)
			prison:SetCanTakeDamage(false)
			prison:SetCanBeKilled(false)
			prison:SetReclaimable(false)
			prison:SetCustomName('Ban Jail')
			ScenarioFramework.Dialogue(VOStrings.Save, nil, true)

			---@type ObjectiveTarget
			return {
				Units = { prison },
			}
		end)
		:OnSuccess(function()
			ScenarioFramework.Dialogue(VOStrings.Saved, nil, true)
			for _, name in prizoners do
				local unit = ScenarioUtils.CreateArmyUnit('Player1', 'Rescued_player')
				unit:SetCustomName(name)
				unit:SetMaxHealth(1)
				unit:GetWeapon(1):AddDamageMod(4000)
			end
		end)
		:Create(),




}


function OnPopulate()
	Game.Armies.Initialize()

	playersManager:Init
	{
		enhancements = {
			Aeon = {
				"AdvancedEngineering",
				"T3Engineering",
				"ResourceAllocation",
				"ResourceAllocationAdvanced",
				"EnhancedSensors"
			},
			Cybran = {
				"AdvancedEngineering",
				"T3Engineering",
				"ResourceAllocation",
				"MicrowaveLaserGenerator"
			},
			UEF = {
				"AdvancedEngineering",
				"T3Engineering",
				"ResourceAllocation",
				"Shield",
				"ShieldGeneratorField"
			},
			Seraphim = {
				"AdvancedEngineering",
				"T3Engineering",
				"DamageStabilization",
				"DamageStabilizationAdvanced",
				"ResourceAllocation",
				"ResourceAllocationAdvanced"
			}
		},
		{
			color = "ff0000ff",
			units =
			{
				Aeon = 'AeonPlayer_1',
				Cybran = 'CybranPlayer_1',
				UEF = 'UEFPlayer_1',
				Seraphim = 'SeraPlayer_1',
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
		},
	}
	Game.Armies.SetUnitCap(ScenarioInfo.Yudi, 4000)

	ScenarioUtils.CreateArmyGroup('TheWheelie', 'P1Qbases')
	--ScenarioUtils.CreateArmyGroup('Yudi', 'MainBase')

end

function OnStart(self)


	Game.SetPlayableArea('StartArea', false)
	Game.Armies.SetColor("Yudi", "FFDD78F1")
	Game.Armies.SetColor("TheWheelie", "FF022B1B")

	Brains.TheWheelie = ArmyBrains[ScenarioInfo.TheWheelie]
	Brains.Yudi = ArmyBrains[ScenarioInfo.Yudi]

	buffDef = Buffs['CheatIncome']
	buffAffects = buffDef.Affects
	buffAffects.EnergyProduction.Mult = 1.5
	buffAffects.MassProduction.Mult = 2.0


	import("/maps/Test/YudiOpAI.lua").Main()
	for _, u in Brains.Yudi:GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
		Buff.ApplyBuff(u, 'CheatIncome')
	end
	objectives:Start("start")
end
