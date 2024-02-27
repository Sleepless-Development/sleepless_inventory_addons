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
RECIPES = {
    ['garbage scrapmetal'] = {
        duration = 2000,
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
            ['garbage'] = { need = 1, remove = true },
            ['scrapmetal'] = { need = 0.1, remove = true },
        },
        result = {
            { name = 'lockpick', amount = 1 },
            -- { name = 'something', amount = 1 }
        },
    },
    -- Additional recipes can be added here
}

return RECIPES
