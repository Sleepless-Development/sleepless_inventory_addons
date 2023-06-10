RECIPES = { --create new item craft Recipies here. limited to 2 items per craft

    ['garbage'] = { --item1
        otherItem = 'scrapmetal', --item2
        duration = 2000, --how long the craft takes
        result = { -- the items you get after craft. can add as many different item/amounts as you want
            {name = 'lockpick', amount = 1},
         -- {name = 'something', amount = 1}
        },
        costs = { --amount of both items needed to craft and if they should be removed on finished
            ['garbage'] = {need = 1, remove = true}, -- item 1
            ['scrapmetal'] = {need = 1, remove = true}, -- item 2
        },
    },

}
