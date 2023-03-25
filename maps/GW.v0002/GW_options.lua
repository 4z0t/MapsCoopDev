options = {
    {
        default = 1,
        label = "ACU death type",
        help = "Choose how mission fails when player's ACU dies",
        key = 'ACUDeathType',
        pref = 'ACUDeathType',
        values = {
            { text = "all", help = "Mission fails when all players' ACUs are dead", key = 1, },
            { text = "any", help = "Mission fails when any of players' ACU dies", key = 2, },
        },
    },
}
