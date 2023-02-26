version = 3 -- Lua Version. Dont touch this
ScenarioInfo = {
    name = "GW",
    description = "",
    preview = '',
    map_version = 2,
    type = 'campaign_coop',
    starts = true,
    size = {1024, 1024},
    reclaim = {461680, 0},
    map = '/maps/GW.v0002/GW.scmap',
    save = '/maps/GW.v0002/GW_save.lua',
    script = '/maps/GW.v0002/GW_script.lua',
    norushradius = 40,
    Configurations = {
        ['standard'] = {
            teams = {
                {
                    name = 'FFA',
                    armies = {'ARMY_1', 'ARMY_2'}
                },
            },
            customprops = {
            },
        },
    },
}
