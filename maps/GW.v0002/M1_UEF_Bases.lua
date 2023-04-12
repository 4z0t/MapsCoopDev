local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local TauntManager = import('/lua/TauntManager.lua')
local BC = Oxygen.BuildConditions
local BaseManager = Oxygen.BaseManagers.CustomBaseManager
local DV = Oxygen.DifficultyValues

local tauntUEF = TauntManager.CreateTauntManager("UEF", Oxygen.ScenarioFolder "VOStrings.lua")

---@type CustomBaseManager
local neBase = BaseManager()
---@type CustomBaseManager
local swBase = BaseManager()
---@type CustomBaseManager
local seBase = BaseManager()

---@type NukeBaseManger
local nukeBase = Oxygen.BaseManagers.NukeBaseManger()


function NukeBase()
    nukeBase:Initialize(Oxygen.Brains.UEF, "M1_Nuke_Base", "M1_Nuke_Base_M", 10, {
        ["M1_Nuke_Base"] = 1000,
        ["M1_Nuke_Stealth"] = 2000,
    })
    nukeBase:StartEmptyBase(5)
    nukeBase:SortGroupNames()

    nukeBase:SetBuildAllStructures(true)
    nukeBase:SetActive('Nuke', true)

    nukeBase.MaximumConstructionEngineers = 5
end

DV.M1_NE_EngineersCount = { 7, 10, 15 }
DV.M1_NE_AssistersCount = { 5, 7, 10 }



function NEBase()
    neBase:InitializeDifficultyTables(Oxygen.Brains.UEF, "M1_NE_Base", "M1_NE_Base_M", 100,
        {
            ["M1_NE_Base"] = 1000,
        }
    )
    neBase:StartNonZeroBase { DV.M1_NE_EngineersCount, DV.M1_NE_AssistersCount }
    neBase:SetActive('AirScouting', true)
    neBase:SetBuildAllStructures(true)

    neBase:SetBuildTransports(true)
    neBase:SetTransportsTech(2)
    neBase.TransportsNeeded = 3

    neBase:LoadPlatoonsFromFile()
end

DV.M1_SW_EngineerCount = { 4, 7, 10 }
DV.M1_SW_AssisterCount = { 2, 4, 6 }


function SWBase()
    swBase:InitializeDifficultyTables(Oxygen.Brains.UEF, "M1_SW_Base", "M1_SW_Base_M", 65,
        {
            ["M1_SW_Base"] = 1000
        }
    )
    swBase:StartNonZeroBase { DV.M1_SW_EngineerCount, DV.M1_SW_AssisterCount }
    swBase:SetActive('AirScouting', true)
    swBase:SetBuildAllStructures(true)


    swBase:SetBuildTransports(true)
    swBase:SetTransportsTech(2)
    swBase.TransportsNeeded = 3

    swBase:LoadPlatoonsFromFile()

end

DV.M1_SE_EngineerCount = { 10, 20, 30 }
DV.M1_SE_AssisterCount = { 7, 15, 20 }


function SEBase()
    ScenarioInfo.UEFacu = Oxygen.Game.Armies.CreateUnit("UEF", "UEF_ACU")

    seBase:InitializeDifficultyTables(Oxygen.Brains.UEF, "M1_SE_Base", "M1_SE_Base_M", 150, { ["M1_SE_Base"] = 1000 })
    seBase:StartNonZeroBase { DV.M1_SE_EngineerCount, DV.M1_SE_AssisterCount }
    seBase:SetActive('AirScouting', true)
    seBase:SetBuildAllStructures(true)
    seBase:SetACUUpgrades(
        {
            "Shield",
            "T3Engineering",
            "ResourceAllocation"
        }, true)

    seBase:SetBuildTransports(true)
    seBase:SetTransportsTech(3)
    seBase.TransportsNeeded = 2
    seBase.MaximumConstructionEngineers = 15

    seBase:LoadPlatoonsFromFile()


    if DV.M1_SE_BuildAirDefenses then
        seBase:AddBuildStructures("M1_SE_Air", {
            Priority = 2000,
            BuildConditions =
            {
                BC.HumansCategoryCondition(categories.AIR, ">=", 30),
                BC.HumansBuiltOrActiveCategoryCondition(categories.AIR * categories.EXPERIMENTAL, ">", 0)
            }
        })
    end

    if DV.M1_SE_BuildLandDefenses then
        seBase:AddBuildStructures("M1_SE_Land", {
            Priority = 1800,
            BuildConditions =
            {
                BC.HumansCategoryCondition(categories.LAND * categories.MOBILE, ">=", 30),
                BC.HumansBuiltOrActiveCategoryCondition(categories.EXPERIMENTAL * categories.LAND, ">", 0)
            }
        })
    end


    seBase:AddUnitAI("M1_Fatboy",
        {
            PlatoonAIFunction = { Oxygen.PlatoonAI.Common, "PatrolChainPickerThread" },
            PlatoonData = {
                PatrolChains = {
                    "M1_LAC3",
                    "M1_LAC6",
                },
            },
            Priority = 2500,
            Amount = DV.M1_SE_FatboyAmout,
            KeepAlive = true,
            Retry = true,
            MaxAssist = DV.M1_SE_FatboyAssist,
            BuildCondition =
            {
                BC.HumansCategoryCondition(categories.DEFENSE * categories.DIRECTFIRE, ">=", 10),
                BC.HumansCategoryCondition(categories.SHIELD * categories.STRUCTURE, ">=", 5),
                BC.HumansEconomyCondition("AvgMassIncome", ">=", 200),
            }
        })
end

function Main()
    Oxygen.Game.Armies.CreateGroup("UEF", 'M1_SW_Power', true)

    tauntUEF:AddPlayerIntelCategoryTaunt("M1_UEF_Locate_Taunt", Oxygen.Brains.UEF, categories.ALLUNITS)

    NEBase()
    SWBase()
    SEBase()
    NukeBase()
end
