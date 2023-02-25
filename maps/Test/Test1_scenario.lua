version = 3 -- Lua Version. Dont touch this
ScenarioInfo = {
    name = "COOP",
    description = "AAAAAAAAAAAAAA",
    preview = '',
    map_version = 1,
    type = 'campaign_coop',
    starts = true,
    size = {1024, 1024},
    reclaim = {563529.8, 283701.1},
    map = '/maps/Test/Test1.scmap',
    save = '/maps/Test/Test1_save.lua',
    script = '/maps/Test/Test1_script.lua',
    norushradius = 40,
    Configurations = {
        ['standard'] = {
            teams = {
                {
                    name = 'FFA',
                    armies = {'Player1', 'TheWheelie', 'Yudi', 'Player2', 'Player3', 'Player4'}
                },
            },
            customprops = {
            },
        },
    },
}
