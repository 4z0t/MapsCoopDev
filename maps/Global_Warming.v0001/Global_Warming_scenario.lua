version = 3 -- Lua Version. Dont touch this
ScenarioInfo = {
    name = "Global Warming",
    description = "",
    preview = '',
    map_version = 1,
    type = 'skirmish',
    starts = true,
    size = {1024, 1024},
    reclaim = {12186, 0},
    map = '/maps/Global_Warming.v0001/Global_Warming.scmap',
    save = '/maps/Global_Warming.v0001/Global_Warming_save.lua',
    script = '/maps/Global_Warming.v0001/Global_Warming_script.lua',
    norushradius = 40,
    Configurations = {
        ['standard'] = {
            teams = {
                {
                    name = 'FFA',
                    armies = {'ARMY_1', 'ARMY_2', 'ARMY_3', 'ARMY_4', 'ARMY_5', 'Yudi'}
                },
            },
            customprops = {
            },
        },
    },
}
