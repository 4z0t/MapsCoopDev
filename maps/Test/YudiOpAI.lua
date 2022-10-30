local PlatoonBuilder = import("/lua/ASF/PlatoonBuilder.lua")
local OpAIBuilder = import("/lua/ASF/OpAIBuilder.lua").OpAIBuilder
local PlatoonLoader = import("/lua/ASF/PlatoonLoader.lua").PlatoonLoader
local UNIT = import("/lua/ASF/UnitNames.lua").Get
local BaseManager = import('/lua/ai/opai/basemanager.lua')
local DifficultyValue = import("/lua/ASF/DifficultyValue.lua")
local DV = DifficultyValue.Get

local SPAIFileName = '/lua/scenarioplatoonai.lua'


local mainBase = BaseManager.CreateBaseManager()


DifficultyValue.Extend {

    ["Engi Base count"] = { 10, 15, 20 },
    ["Engi Base assisters"] = { 7, 12, 15 },

    ["Brick count"] = { 3, 4, 5 },
    ["Banger count"] = { 1, 2, 3 },
    ["Deceiver count"] = { 0, 0, 1 },

    ["M Brick count"] = { 6, 8, 10 },
    ["M Banger count"] = { 3, 4, 5 },
    ["M Deceiver count"] = { 0, 1, 2 }
}

function Main()
    mainBase:InitializeDifficultyTables(Brains.Yudi, "YudiBase", "YudiBase_M", 100, { MainBase = 1500 })
    mainBase:StartNonZeroBase { DV "Engi Base count", DV "Engi Base assisters" }
    mainBase:SetActive('AirScouting', true)

    local pb = PlatoonBuilder.Create()
        :UseAIFunction(SPAIFileName, "PatrolChainPickerThread")
        :UseType('Land')
    ---@type OpAIBuilder
    local opAIb = OpAIBuilder()



    ---@type PlatoonLoader
    local pl = PlatoonLoader(mainBase)
    pl:LoadPlatoons {
        pb:Default "Brick Attack"
            :InstanceCount(5)
            :Priority(200)
            :AddGroupDefault(UNIT "Brick", DV "Brick count")
            :AddGroupDefault(UNIT "Banger", DV "Banger count")
            :AddGroupDefault(UNIT "Deceiver", DV "Deceiver count")
            :Data
            {
                PatrolChains = {
                    "LAC01",
                    "LAC02",
                    "LAC03",
                }
            }
            :Create(),
        pb:Default "Lone Brick"
            :InstanceCount(3)
            :Priority(100)
            :AddGroupDefault(UNIT "Brick", 1)
            :AddGroupDefault(UNIT "Deceiver", DV "Deceiver count")
            :Data
            {
                PatrolChains = {
                    "LAC01",
                    "LAC02",
                    "LAC03",
                }
            }
            :Create(),
        pb:Default "Massive Brick Attack"
            :InstanceCount(2)
            :Priority(150)
            :AddGroupDefault(UNIT "Brick", DV "M Brick count")
            :AddGroupDefault(UNIT "Banger", DV "M Banger count")
            :AddGroupDefault(UNIT "Deceiver", DV "M Deceiver count")
            :AddGroupDefault(UNIT "Medusa", DV "M Brick count")
            :Data
            {
                PatrolChains = {
                    "LAC01",
                    "LAC02",
                    "LAC03",
                }
            }
            :Create(),

    }

    pl:LoadOpAIs
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
            :NewBuildGroup "ExpBug"
            :Data
            {
                MasterPlatoonFunction = { SPAIFileName, 'PatrolChainPickerThread' },
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





end
