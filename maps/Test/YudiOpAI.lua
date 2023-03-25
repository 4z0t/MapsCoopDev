local PlatoonBuilder = Oxygen.PlatoonBuilder
local OpAIBuilder = Oxygen.OpAIBuilder
local UNIT = Oxygen.UnitNames.Get
local AdvancedBaseManager = Oxygen.AdvancedBaseManager
local DifficultyValue = Oxygen.DifficultyValue
local DV = DifficultyValue.Get
local BC = Oxygen.BuildConditions

local SPAIFileName = '/lua/scenarioplatoonai.lua'
local BMPT = '/lua/ai/opai/BaseManagerPlatoonThreads.lua'

---@type AdvancedBaseManager
local mainBase = AdvancedBaseManager()
---@type AdvancedBaseManager
local seBase = AdvancedBaseManager()




DifficultyValue.Extend {

    ["Engi Base count"] = { 10, 15, 20 },
    ["Engi Base assisters"] = { 7, 10, 12 },

    ["Brick count"] = { 3, 4, 5 },
    ["Banger count"] = { 1, 2, 3 },
    ["Deceiver count"] = { 0, 0, 1 },

    ["Rhino count"] = { 3, 4, 5 },

    ["M Brick count"] = { 6, 8, 10 },
    ["M Banger count"] = { 3, 4, 5 },
    ["M Deceiver count"] = { 0, 1, 2 },

    ["ASF attack count"] = { 15, 20, 25 },

    ["Flying Bricks count"] = { 5, 7, 10 },

    ["RAS Bois count"] = { 10, 30, 5 },

}

---@type NukeBaseManger
local nukeBase = Oxygen.BaseManagers.NukeBaseManger()

function SetupSEBase()

    seBase:Initialize(Brains.Yudi, "SE_BASE", "SE_Base_M", 50, { ["SE Base"] = 1500 })
    seBase:StartEmptyBase(DV "Engi Base assisters")
    seBase:SetActive('AirScouting', true)
    seBase:SetBuildAllStructures(true)
    seBase.MaximumConstructionEngineers = 10



    ---@type PlatoonTemplateBuilder
    local pb = PlatoonBuilder()
    pb
        :UseAIFunction(Oxygen.PlatoonAI.Common, "PatrolChainPickerThread")
        :UseLocation "SE_BASE"
        :UseType 'Land'
        :UseData
        {
            PatrolChains = {
                "LAC01",
                "LAC02",
                "LAC03",
            },
            Offset = 10
        }

    seBase:LoadPlatoons {
        pb:New "Rhinos SE"
            :InstanceCount(5)
            :Priority(280)
            :AddUnit(UNIT "Rhino", 4)
            :AddUnit(UNIT "Deceiver", DV "Deceiver count")
            :Create(),

        pb:New "Bomber attack"
            :Type "Air"
            :InstanceCount(5)
            :Priority(100)
            :AddUnit(UNIT "Zeus", 5)
            :Data
            {
                PatrolChains =
                {
                    "SE_bomber_chain"
                }
            }
            :Create()
    }
end

function NukeBase()

    nukeBase:Initialize(Brains.Yudi, "NukeBaseGroup", "NukeBase_M", 30, {
        Nuke = 1500,
        Defense = 2000,
    })
    nukeBase:StartEmptyBase(DV "RAS Bois count")
    nukeBase:SortGroupNames()

    nukeBase:SetBuildAllStructures(true)
    nukeBase:SetActive('Nuke', true)

    nukeBase.PermanentAssistCount = DV "RAS Bois count"

end

function Main()
    mainBase:InitializeDifficultyTables(Brains.Yudi, "YudiBase", "YudiBase_M", 100, { MainBase = 1000 })
    mainBase:StartNonZeroBase { DV "Engi Base count", DV "Engi Base assisters" }
    mainBase:SetActive('AirScouting', true)
    mainBase:SetBuildAllStructures(true)
    mainBase:AddBuildGroup('BoiProd', 2000, false, false)
    mainBase:SetACUUpgrades({ "T3Engineering" }, false)
    mainBase:SetBuildTransports(true)
    mainBase:SetTransportsTech(2)
    mainBase.TransportsNeeded = 7

    ---@type PlatoonTemplateBuilder
    local pb = PlatoonBuilder()
    pb
        :UseAIFunction(Oxygen.PlatoonAI.Common, "PatrolChainPickerThread")
        :UseLocation "YudiBase"
        :UseType 'Land'
        :UseData
        {
            PatrolChains = {
                "LAC01",
                "LAC02",
                "LAC03",
            },
            Offset = 20
        }


    mainBase:LoadPlatoons {
        pb:New "Brick Attack"
            :InstanceCount(5)
            :Priority(200)
            :AddUnits
            {
                { UNIT "Brick", DV "Brick count" },
                { UNIT "Banger", DV "Banger count" },
                { UNIT "Deceiver", DV "Deceiver count" },
            }
            :Create(),


        pb:New "Lone Brick"
            :InstanceCount(3)
            :Priority(100)
            :AddUnit(UNIT "Brick", 1)
            :AddUnit(UNIT "Deceiver", DV "Deceiver count")
            :Create(),

        pb:New "Flying Brick"
            :InstanceCount(3)
            :Priority(250)
            :AddUnit(UNIT "Brick", 1)
            :AddUnit(UNIT "Deceiver", DV "Deceiver count")
            :AIFunction('/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports')
            :Data
            {
                TransportReturn = "YudiBase_M",
                TransportChain = "FlyingBrickRoute",
                LandingChain = "FlyingBrickLanding",
                AttackChain = "TransportAttack"
            }
            :Create(),

        pb:New "Flying Bricks"
            :InstanceCount(1)
            :Priority(50)
            :AddUnit(UNIT "Brick", DV "Flying Bricks count")
            :AddUnit(UNIT "Deceiver", DV "Deceiver count" * 5)
            :AIFunction('/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports')
            :Data
            {
                TransportReturn = "YudiBase_M",
                TransportChain = "FlyingBrickRoute",
                LandingChain = "FlyingBrickLanding",
                AttackChain = "TransportAttack"
            }
            :AddCondition(BC.ArmyCategoryCondition("HumanPlayers", categories.LAND, ">", 10))
            :Create(),


        pb:New "SE Engineers"
            :InstanceCount(1)
            :Priority(500)
            :AddUnit(UNIT "T3 Cybran Engineer", 5)
            :Data
            {
                UseTransports = true,
                TransportReturn = "YudiBase_M",
                TransportChain = "SE_Base_chain",
                LandingLocation = "SE_Base_M",
            }
            :Create(Oxygen.BaseManager.Platoons.ExpansionOf "SE_BASE"),

        pb:New "Massive Brick Attack"
            :InstanceCount(2)
            :Priority(150)
            :AddUnit(UNIT "Brick", DV "M Brick count")
            :AddUnit(UNIT "Banger", DV "M Banger count")
            :AddUnit(UNIT "Deceiver", DV "M Deceiver count")
            :AddUnit(UNIT "Medusa", DV "M Brick count")
            :Create(),

        pb:New "Rhinos"
            :InstanceCount(5)
            :Priority(280)
            :AddUnit(UNIT "Rhino", 4)
            :AddUnit(UNIT "Deceiver", DV "Deceiver count")
            :Difficulties { "Medium", "Easy" }
            :Create(),

        pb:New "bois"
            :Type "Gate"
            :Priority(500)
            :AddUnit(UNIT "Cybran RAS SACU", DV "RAS Bois count")
            :Create(Oxygen.BaseManager.Platoons.ExpansionOf "NukeBaseGroup"),

        pb:New "Arty attack"
            :Type "Land"
            :Priority(500)
            :AddUnits(Oxygen.Misc.FromMapUnits("Yudi", "ArtyAttack", 'Artillery', 'GrowthFormation'))
            :Create(),

        pb:New "Loyas attack"
            :Type "Land"
            :Priority(500)
            :AddUnits(Oxygen.Misc.FromMapUnitsDifficulty("Yudi", "Loyas", "Attack", 'GrowthFormation'))
            :Create(Oxygen.Platoons.NavigateTo "AhwassaDropTarget"),
    }


    ---@type OpAIBuilder
    local opAIb = OpAIBuilder()

    ---@type AirAttacksOpAIBuilder
    local airOpAIb = Oxygen.OpAIBuilders.AirAttacks()

    airOpAIb
        :UseAIFunction(SPAIFileName, 'CategoryHunterPlatoonAI')

    ---@type EngineerAttacksOpAIBuilder
    local engyOpAIb = Oxygen.OpAIBuilders.EngineerAttacks()


    ---@type LandAttacksOpAIBuilder
    local landOpAIb = Oxygen.OpAIBuilders.LandAttacks()

    mainBase:LoadOpAIs
    {

        landOpAIb
            :New "TEST"
            :EnableChild("HeavyBots")
            :EnableChild("MobileStealth")
            :EnableChild("MobileFlak")
            :EnableChild("SiegeBots")
            :ChildCount(1)
            :AIFunction(SPAIFileName, 'PatrolChainPickerThread')
            :Data
            {
                PatrolChains = {
                    "LAC01",
                    "LAC02",
                    "LAC03",
                },
            }
            :Priority(500)
            :Create(),

        engyOpAIb
            :New "Engi attack"
            :Quantity("T2Engineers", 4)
            :EnableChild('T2Engineers')
            :AIFunction(SPAIFileName, 'SplitPatrolThread')
            :Data
            {
                PatrolChains = {
                    "LAC01",
                    "LAC02",
                    "LAC03",
                },
            }
            :AddCondition(BC.BrainEconomyCondition("MassStorage", "<", 5000))
            :Priority(300)
            :Create(),


        airOpAIb
            :New "ASF attack"
            :Priority(250)
            :Quantity('AirSuperiority', DV "ASF attack count")
            :Data
            {
                CategoryList = { categories.AIR },
            }
            :Create(),

        airOpAIb
            :New "Bombers"
            :Priority(300)
            :Quantity("Bombers", 5)
            :TargettingPriorities { categories.ENGINEER - categories.COMMAND - categories.SUBCOMMANDER }
            :Data
            {
                CategoryList = { categories.LAND },
            }
            :Create(),

        airOpAIb
            :New "Strats"
            :Priority(500)
            :Data
            {
                CategoryList = { categories.MASSPRODUCTION }
            }
            :Quantity("StratBombers", 5)
            :EnableChild("StratBombers")
            :AddCondition(BC.HumansEconomyCondition("MassIncome", ">=", 300))
            :Create(),

        opAIb
            :NewBuildGroup "ExpBug"
            :Data
            {
                PlatoonAIFunction = { SPAIFileName, 'PatrolChainPickerThread' },
                PlatoonData = {
                    PatrolChains = {
                        "LAC01",
                        "LAC02",
                        "LAC03",
                    },
                },
                MaxAssist = 4,
                Retry = true,
                KeepAlive = true,
                Amount = 2,
            }
            :HumansCategoryCondition(categories.EXPERIMENTAL, ">=", 1)
            :Create(),



    }




    mainBase:AddBuildStructures("AirDefense", {
        Priority = 2000,
        BuildConditions =
        {
            BC.HumansCategoryCondition(categories.AIR, ">=", 30),
            BC.HumansBuiltOrActiveCategoryCondition(categories.AIR * categories.EXPERIMENTAL, ">", 0)
        }
    })

    mainBase:AddBuildStructures("LandDefense", {
        Priority = 1800,
        BuildConditions =
        {
            BC.HumansCategoryCondition(categories.LAND, ">=", 30)
        }
    })
    mainBase.MaximumConstructionEngineers = 20

    NukeBase()
    SetupSEBase()

end
