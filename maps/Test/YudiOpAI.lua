local PlatoonBuilder = import("/lua/ASF/PlatoonBuilder.lua")
local OpAIBuilder = import("/lua/ASF/OpAIBuilder.lua").OpAIBuilder
local PlatoonLoader = import("/lua/ASF/PlatoonLoader.lua").PlatoonLoader
local UNIT = import("/lua/ASF/UnitNames.lua").Get
local BaseManager = import('/lua/ai/opai/basemanager.lua')
local DifficultyValue = import("/lua/ASF/DifficultyValue.lua")
local DV = DifficultyValue.Get

local SPAIFileName = '/lua/scenarioplatoonai.lua'


local mainBase = BaseManager.CreateBaseManager()

function Main()
    mainBase:InitializeDifficultyTables(Brains.Yudi, "YudiBase", "YudiBase_M", 100, { MainBase = 1500 })
    mainBase:StartNonZeroBase({ { 7, 10, 12 }, { 5, 8, 10 } })
    mainBase:SetActive('AirScouting', true)

    local pb = PlatoonBuilder.Create()
        :UseAIFunction(SPAIFileName, "PatrolChainPickerThread")
        :UseType('Land')
    ---@type OpAIBuilder
    local opAIb = OpAIBuilder()

    DifficultyValue.Extend {
        ["Brick count"] = { 3, 4, 5 },
        ["Banger count"] = { 1, 2, 3 },
        ["Deceiver count"] = { 0, 0, 1 },

        ["M Brick count"] = { 6, 8, 10 },
        ["M Banger count"] = { 3, 4, 5 },
        ["M Deceiver count"] = { 0, 1, 2 }
    }

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
            :Priority(100)
            :AddGroupDefault(UNIT "Brick", DV "M Brick count")
            :AddGroupDefault(UNIT "Banger", DV "M Banger count")
            :AddGroupDefault(UNIT "Deceiver", DV "M Deceiver count")
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


    }



end
