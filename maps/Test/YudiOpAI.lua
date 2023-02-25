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

    ["RAS Bois count"] = { 10, 30, 50 },

}

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
    }
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
                    BaseTemplate = "Scathis",
                    BuildClose = true,
                },
                MaintainBaseTemplate = "Scathis"
            }
            :Create(),
    }


    ---@type OpAIBuilder
    local opAIb = OpAIBuilder()
    mainBase:LoadOpAIs
    {

        opAIb
            :New "Engi attack"
            :Type "EngineerAttack"
            :Quantity("T1Engineer", 4)
            :Data
            {
                MasterPlatoonFunction = { SPAIFileName, 'SplitPatrolThread' },
                PlatoonData = {
                    PatrolChains = {
                        "LAC01",
                        "LAC02",
                        "LAC03",
                    },
                },
                Priority = 300,
            }
            :Create(),

        opAIb
            :New "ASF attack"
            :Type "AirAttacks"
            :Data
            {
                MasterPlatoonFunction = { SPAIFileName, 'CategoryHunterPlatoonAI' },
                PlatoonData = {
                    CategoryList = { categories.AIR },
                },
                Priority = 250,
            }
            :Quantity("AirSuperiority", DV "ASF attack count")
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

    SetupSEBase()

end
