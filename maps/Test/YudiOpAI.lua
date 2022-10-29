local PlatoonBuilder = import("/lua/ASF/PlatoonBuilder.lua")
local PlatoonLoader = import("/lua/ASF/PlatoonLoader.lua").PlatoonLoader
local UNIT = import("/lua/ASF/UnitNames.lua").Get
local BaseManager = import('/lua/ai/opai/basemanager.lua')
local DifficultyValue = import("/lua/ASF/DifficultyValue.lua")
local DV = DifficultyValue.Get

local SPAIFileName = '/lua/scenarioplatoonai.lua'


local mainBase = BaseManager.CreateBaseManager()

function Main()
    mainBase:InitializeDifficultyTables(Brains.Yudi, "YudiBase", "YudiBase_M", 100, {})
    mainBase:StartNonZeroBase({ { 7, 10, 12 }, { 5, 8, 10 } })
    mainBase:SetActive('AirScouting', true)

    local pb = PlatoonBuilder.Create()
        :UseAIFunction(SPAIFileName, "PatrolChainPickerThread")
        :UseType('Land')


    DifficultyValue.Extend {
        ["Brick count"] = { 3, 4, 5 },
        ["Banger count"] = { 1, 2, 3 },
        ["Deceiver count"] = { 0, 0, 1 }
    }

    ---@type PlatoonLoader
    local pl = PlatoonLoader(mainBase)
    pl:LoadPlatoons {
        pb:Default "Brick Attack"
            :InstanceCount(10)
            :Priority(100)
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
            :Create()

    }


end
