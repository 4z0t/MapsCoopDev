version = 3 -- Lua Version. Dont touch this
ScenarioInfo = {
    name = "Global Warning",
    description = "",
    preview = '',
    map_version = 2,
    type = 'campaign_coop',
    starts = true,
    size = { 1024, 1024 },
    reclaim = { 509660, 0 },
    map = '/maps/GW.v0002/GW.scmap',
    save = '/maps/GW.v0002/GW_save.lua',
    script = '/maps/GW.v0002/GW_script.lua',
    norushradius = 40,
    Configurations = {
        ['standard'] = {
            teams = {
                {
                    name = 'FFA',
                    armies = { 'Player1', 'UEF', 'Cybran', 'Aeon', 'Unknown', 'Player2', 'Player3', 'Player4', 'Player5' }
                },
            },
            customprops = {
            },
            factions = {
                { 'uef', 'aeon', 'cybran' },
                { 'uef', 'aeon', 'cybran' },
                { 'uef', 'aeon', 'cybran' },
                { 'uef', 'aeon', 'cybran' },
                { 'uef', 'aeon', 'cybran' }
            },
        },
    },
}
