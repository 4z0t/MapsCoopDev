local PlatoonBuilder = Oxygen.PlatoonBuilder
local OpAIBuilder = Oxygen.OpAIBuilder
local UNIT = Oxygen.UnitNames.Get
local AdvancedBaseManager = Oxygen.BaseManager
local DifficultyValue = Oxygen.DifficultyValue
local DV = DifficultyValue.Get
local BC = Oxygen.BuildConditions

local SPAIFileName = '/lua/scenarioplatoonai.lua'
local YPAIFileName = '/maps/Test/YudiPlatoonAI.lua'

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
        :UseAIFunction(SPAIFileName, "PatrolChainPickerThread")
        :UseLocation "SE_BASE"
        :UseType 'Land'
        :UseData
        {
            PatrolChains = {
                "LAC01",
                "LAC02",
                "LAC03",
            }
        }

    seBase:LoadPlatoons {
        pb:NewDefault "Rhinos SE"
            :InstanceCount(5)
            :Priority(280)
            :AddUnitDefault(UNIT "Rhino", 4)
            :AddUnitDefault(UNIT "Deceiver", DV "Deceiver count")
            :Create(),

        pb:NewDefault "Bomber attack"
            :Type "Air"
            :InstanceCount(5)
            :Priority(100)
            :AddUnitDefault(UNIT "Zeus", 5)
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
    }, true)
    nukeBase:StartEmptyBase(0)

    nukeBase:SetBuildAllStructures(true)
    nukeBase:SetActive('Nuke', true)

    nukeBase.PermanentAssistCount = DV "RAS Bois count"


end

function Main()
    mainBase:InitializeDifficultyTables(Brains.Yudi, "YudiBase", "YudiBase_M", 100, { MainBase = 1000 }, true)
    mainBase:StartNonZeroBase { DV "Engi Base count", DV "Engi Base assisters" }
    mainBase:SetActive('AirScouting', true)
    mainBase:SetBuildAllStructures(true)
    --mainBase:SetSACUUpgrades { "ResourceAllocation" }
    mainBase:AddBuildGroup('BoiProd', 2000, false, false)
    mainBase:SetACUUpgrades({ "AdvancedEngineering", "T3Engineering" }, false)
    mainBase:SetBuildTransports(true)
    mainBase.TransportsNeeded = 7

    ---@type PlatoonTemplateBuilder
    local pb = PlatoonBuilder()
    pb
        :UseAIFunction(SPAIFileName, "PatrolChainPickerThread")
        :UseLocation "YudiBase"
        :UseType 'Land'
        :UseData
        {
            PatrolChains = {
                "LAC01",
                "LAC02",
                "LAC03",
            }
        }


    mainBase:LoadPlatoons {
        pb:NewDefault "Brick Attack"
            :InstanceCount(5)
            :Priority(200)
            :AddUnitDefault(UNIT "Brick", DV "Brick count")
            :AddUnitDefault(UNIT "Banger", DV "Banger count")
            :AddUnitDefault(UNIT "Deceiver", DV "Deceiver count")
            :Create(),


        pb:NewDefault "Lone Brick"
            :InstanceCount(3)
            :Priority(100)
            :AddUnitDefault(UNIT "Brick", 1)
            :AddUnitDefault(UNIT "Deceiver", DV "Deceiver count")
            :Create(),

        pb:NewDefault "Flying Brick"
            :InstanceCount(3)
            :Priority(250)
            :AddUnitDefault(UNIT "Brick", 1)
            :AddUnitDefault(UNIT "Deceiver", DV "Deceiver count")
            :AIFunction('/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports')
            :Data
            {
                TransportReturn = "YudiBase_M",
                TransportChain = "FlyingBrickRoute",
                LandingChain = "FlyingBrickLanding",
                AttackChain = "TransportAttack"
            }
            :Create(),

        pb:NewDefault "Flying Bricks"
            :InstanceCount(1)
            :Priority(50)
            :AddUnitDefault(UNIT "Brick", DV "Flying Bricks count")
            :AddUnitDefault(UNIT "Deceiver", DV "Deceiver count" * 5)
            :AIFunction('/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports')
            :Data
            {
                TransportReturn = "YudiBase_M",
                TransportChain = "FlyingBrickRoute",
                LandingChain = "FlyingBrickLanding",
                AttackChain = "TransportAttack"
            }
            :Create(),


        pb:NewDefault "SE Engineers"
            :InstanceCount(1)
            :Priority(500)
            :AddUnitDefault(UNIT "T3 Cybran Engineer", 5)
            :AIFunction('/lua/ScenarioPlatoonAI.lua', 'StartBaseEngineerThread')
            :Data
            {
                UseTransports = true,
                Construction =
                {
                    BaseTemplate = "SE Base",
                },
                MaintainBaseTemplate = "SE Base",
                TransportChain = "SE_Base_chain",
                LandingLocation = "SE_Base_M"
            }
            :Create(),

        pb:NewDefault "Massive Brick Attack"
            :InstanceCount(2)
            :Priority(150)
            :AddUnitDefault(UNIT "Brick", DV "M Brick count")
            :AddUnitDefault(UNIT "Banger", DV "M Banger count")
            :AddUnitDefault(UNIT "Deceiver", DV "M Deceiver count")
            :AddUnitDefault(UNIT "Medusa", DV "M Brick count")
            :Create(),

        pb:NewDefault "Rhinos"
            :InstanceCount(5)
            :Priority(280)
            :AddUnitDefault(UNIT "Rhino", 4)
            :AddUnitDefault(UNIT "Deceiver", DV "Deceiver count")
            :Difficulties { "Medium", "Easy" }
            :Create(),

        pb:NewDefault "bois"
            :Type "Gate"
            --:AIFunction(YPAIFileName, "BoiBuild")
            :AIFunction(SPAIFileName, "StartBaseEngineerThread")
            :Priority(500)
            :AddUnitDefault(UNIT "Cybran RAS SACU", DV "RAS Bois count")
            :Data
            {
                Construction = {
                    BaseTemplate = "NukeBaseGroup",
                },
                MaintainBaseTemplate = "NukeBaseGroup"
            }
            :Create(),
    }


    ---@type OpAIBuilder
    local opAIb = OpAIBuilder()

    ---@type AirAttacksOpAIBuilder
    local airOpAIb = Oxygen.OpAIBuilders.AirAttacks()

    airOpAIb
        :UseAIFunction(SPAIFileName, 'CategoryHunterPlatoonAI')

    ---@type EngineerAttacksOpAIBuilder
    local engyOpAIb = Oxygen.OpAIBuilders.EngineerAttacks()


    mainBase:LoadOpAIs
    {

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
            :AddCondition(BC.HumansEconomyCondition("MassIncome", ">=", 300 / 10))
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
