local RECIPES = require 'dragCraft.config'

RegisterNetEvent('dragCraft:Craft', function(duration, index)
    local recipe = RECIPES[index]

    TriggerServerEvent('ox_inventory:closeInventory')

    ---@type boolean | nil
    local continue

    if recipe?.client?.before then
        continue = recipe.client.before(recipe)
    end

    if continue == false then
        TriggerServerEvent('dragCraft:success', false)
        return
    end

    local result = lib.progressCircle({
        duration = duration,
        label = 'Crafting...',
        position = 'middle',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
        },
        anim = {
            dict = 'amb@prop_human_parking_meter@male@base',
            clip = 'base'
        },
    })

    TriggerServerEvent('dragCraft:success', result == true)

    if result then
        if recipe?.client?.after then
            recipe.client.after(recipe)
        end
    end
end)

---@param id string
---@param recipe CraftRecipe
local function addRecipe(id, recipe)
    if type(id) ~= 'string' or type(recipe) ~= 'table' then return end

    local existing = RECIPES[id]

    recipe.server = nil

    if existing then
        recipe.client = recipe.client or existing.client
        recipe.duration = recipe.duration or existing.duration
        recipe.costs = recipe.costs or existing.costs
        recipe.result = recipe.result or existing.result
    end

    RECIPES[id] = recipe
end

RegisterNetEvent('dragCraft:syncRecipe', addRecipe)

CreateThread(function()
    local recipes = lib.callback.await('dragCraft:getRuntimeRecipes', false)

    if type(recipes) ~= 'table' then return end

    for id, recipe in pairs(recipes) do
        addRecipe(id, recipe)
    end
end)

exports('addRecipe', addRecipe)
