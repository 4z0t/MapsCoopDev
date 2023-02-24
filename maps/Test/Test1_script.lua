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
local AC = Oxygen.Cinematics
local Game = Oxygen.Game

local VOStrings = import("/maps/Test/VOStrings.lua").lines
local objectiveBuilder = Oxygen.ObjectiveBuilder()
local playersManager = Oxygen.PlayersManager()
local RequireIn = Oxygen.RequireIn
local DifficultyValue = Oxygen.DifficultyValue
local DV = DifficultyValue.Get


ScenarioInfo.TheWheelie = 2
ScenarioInfo.Yudi = 3

---@type table<string, AIBrain>
_G.Brains = {}

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


DifficultyValue.Extend
{
	["Transport Groups count"] = { 1, 3, 5 }
}


local function TitlePreview()
	UI4Sim.Callback
	{
		name = "test",
		fileName = "/maps/Test/UI/main.lua",
		functionName = "CreateUI",
		args = { 1, 2, 3 }
	}
	WaitSeconds(3)
	UI4Sim.Callback
	{
		name = "test",
		fileName = "/maps/Test/UI/main.lua",
		functionName = "DestroyUI",

	}
end

function Mission1Attack()
	---@type PlatoonController
	local transportPlatoonController = Oxygen.PlatoonController()

	for _ = 1, DV "Transport Groups count" do
		transportPlatoonController
			:FromUnitGroupVeteran("Yudi", "Transports", "GrowthFormation", 5)
			:AttackWithTransportsReturnToPool("TransportDrop", "TransportAttack", true)
	end

end

local objectives = Oxygen.ObjectiveManager()

local function PlayerDeath()
	objectives:EndGame(false)
end

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

			---@type UnitsController
			local playersController = Oxygen.UnitsController()

			AC.NISMode(function()

				---@type UnitsController
				local ahwassaController = Oxygen.UnitsController()

				ahwassaController
					:FromMapArmyUnit("Yudi", "Ahwassa_drop")
					:MoveToMarker "AhwassaDropTarget"


				AC.MoveTo("Cam1", 0)
				ScenarioFramework.Dialogue(VOStrings.Start, nil, true)
				WaitSeconds(2)
				--AC.DisplayText("Global\nWarning", 120, 'ffffffff', 'center', 1)
				-- AC.MoveTo("Cam2", 3)
				-- AC.MoveTo("Cam4", 0)
				-- AC.MoveTo("Cam5", 2)
				-- AC.MoveTo("Cam6", 0)
				-- AC.MoveTo("Cam7", 2)
				ScenarioFramework.KillBaseInArea(Brains.TheWheelie, 'StartArea')

				AC.MoveTo("Cam3", 2.5)

				ahwassaController
					:ImmediatelyKill()
				WaitSeconds(1.5)

				playersController:Units(
					playersManager:WarpIn(function()
						ScenarioFramework.Dialogue(VOStrings.E01_D01_010, PlayerDeath, true)
					end)
				)
				playersController
					:ApplyToUnits(function(unit)
						LOG("Making invincible")
						unit.CanTakeDamage = false
					end)

				WaitSeconds(2.5)
				AC.VisionAtLocation("YudiBase_M", 60, Brains.Player1):DestroyOnExit(true)
				AC.MoveTo("BaseCam1", 3)
				AC.MoveTo("BaseCam2", 1)
				AC.MoveTo("Cam3", 4)
			end)

			playersController
				:ApplyToUnits(function(unit)
					LOG("Reseting")
					unit.CanTakeDamage = true
				end)

			ForkThread(TitlePreview)

			objectives:Start "prison"

			ForkThread(Mission1Attack)
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
			color = "ff18DAE0",
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

	Brains.Player1 = ArmyBrains[1]
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
