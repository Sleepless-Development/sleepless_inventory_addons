RECIPES = {                       --create new item craft Recipies here. limited to 2 items per craft

    -- ['garbage scrapmetal'] = { --'item1 item2'
    --     duration = 2000,          --how long the craft takes
    --     result = {                -- the items you get after craft. can add as many different item/amounts as you want
    --         { name = 'lockpick', amount = 1 },
    --         -- {name = 'something', amount = 1}
    --     },
    --     costs = {                                       --amount of both items needed to craft and if they should be removed on finished
    --         ['garbage'] = { need = 1, remove = true },  -- item 1
    --         ['scrapmetal'] = { need = 1, remove = true }, -- item 2
    --     },
    -- },

    ['weed_lemonhaze rolling_paper'] = {
        duration = 3000,
        result = {
            { name = 'lemonhaze_joint', amount = 1 },
        },
        costs = {
            ['weed_lemonhaze'] = { need = 2, remove = true },
            ['rolling_paper'] = { need = 1, remove = true },
        },
    },

    ['weed_lemonhaze backwoodshoney'] = {
        otherItem = 'weed_lemonhaze',
        duration = 3000,
        result = {
            { name = 'lemonhaze_blunt', amount = 1 },
        },
        costs = {
            ['weed_lemonhaze'] = { need = 3, remove = true },
            ['backwoodshoney'] = { need = 1, remove = true },
        },
    },

    ['blueberry_kush rolling_paper'] = {
        duration = 3000,
        result = {
            { name = 'blueberry_joint', amount = 1 },

        },
        costs = {
            ['blueberry_kush'] = { need = 2, remove = true },
            ['rolling_paper'] = { need = 1, remove = true },
        },
    },

    ['blueberry_kush backwoodshoney'] = {
        duration = 3000,
        result = {
            { name = 'blueberry_blunt', amount = 1 },

        },
        costs = {
            ['blueberry_kush'] = { need = 3, remove = true },
            ['backwoodshoney'] = { need = 1, remove = true },
        },
    },

}
