---@diagnostic disable: missing-return

---@class CraftRecipe
---@field duration number ms it takes to craft the recipe.
---@field client? CallbackFunc Contains client-side functions to be executed before and after crafting.
---@field server? CallbackFunc Contains server-side functions to be executed before and after crafting.
---@field result ItemResult[] The items produced as a result of the crafting process.
---@field costs table<string, CraftCost> The resources required for crafting, including their quantities and removal flags.

---@class CallbackFunc
---@field before fun(recipeData: CraftRecipe):boolean
---@field after fun(recipeData: CraftRecipe):boolean

---@class ItemResult
---@field name string The name of the item.
---@field amount number The amount of the item produced.

---@class CraftCost
---@field need number The quantity of the item needed for crafting.
---@field remove boolean Whether the item should be removed after crafting.

---@type table<string, CraftRecipe>
local RECIPES = {
    ['driedweed rolling_paper'] = {
        duration = 10000,
        client = {
            before = function(recipeData)
                -- some client logic to run before crafting
                -- if this returns false, it will cancel the craft
                -- returning true or nil will continue with the craft
            end,
            after = function(recipeData)
                -- some client logic to run after crafting
                -- returns boolean or nil
            end,
        },
        server = {
            before = function(recipeData)
                -- some server logic to run before crafting
                -- if this returns false, it will cancel the craft
                -- returning true or nil will continue with the craft
            end,
            after = function(recipeData)
                -- some server logic to run after crafting
                -- returns boolean or nil
            end,
        },
        costs = {
            ['driedweed'] = { need = 1, remove = true },
            ['rolling_paper'] = { need = 2, remove = true },
        },
        result = {
            { name = 'joint', amount = 2 },
        },

    },

    ['coke_brick scale'] = {
        duration = 10000,
        client = {
            before = function(recipeData)

            end,
            after = function(recipeData)

            end,
        },
        server = {
            before = function(recipeData)

            end,
            after = function(recipeData)

            end,
        },
        costs = {
            ['coke_brick'] = { need = 1, remove = true },
            ['scale'] = { need = 1, remove = false },
            
        },
        result = {
            { name = 'coke_powder', amount = 8 },
        },

    },

    ['coke_powder emptybag'] = {
        duration = 5000,
        client = {
            before = function(recipeData)

            end,
            after = function(recipeData)

            end,
        },
        server = {
            before = function(recipeData)

            end,
            after = function(recipeData)

            end,
        },
        costs = {
            ['coke_powder'] = { need = 5, remove = true },
            ['emptybag'] = { need = 5, remove = true },
            
        },
        result = {
            { name = 'coke_pooch', amount = 5 },
        },

    },
   

    ['meth_brick scale'] = {
        duration = 10000,
        client = {
            before = function(recipeData)

            end,
            after = function(recipeData)

            end,
        },
        server = {
            before = function(recipeData)

            end,
            after = function(recipeData)

            end,
        },
        costs = {
            ['meth_brick'] = { need = 1, remove = true },
            ['scale'] = { need = 1, remove = false },
        },
        result = {
            { name = 'meth_powder', amount = 8 },
        },

    },

    ['meth_powder emptybag'] = {
        duration = 5000,
        client = {
            before = function(recipeData)

            end,
            after = function(recipeData)

            end,
        },
        server = {
            before = function(recipeData)

            end,
            after = function(recipeData)

            end,
        },
        costs = {
            ['emptybag'] = { need = 5, remove = true },
            ['meth_powder'] = { need = 5, remove = true },
            
        },
        result = {
            { name = 'meth_pooch', amount = 5 },
        },

    },

}

return RECIPES
