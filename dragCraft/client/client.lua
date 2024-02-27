local RECIPES = require 'dragCraft.config'

RegisterNetEvent('dragCraft:Craft', function(duration, index)
    local recipe = RECIPES[index]

    if not recipe then return end
    TriggerServerEvent('ox_inventory:closeInventory')

    ---@type boolean | nil
    local continue

    if recipe.client?.before then
        continue = recipe.client.before(recipe)
    end

    if continue == false then return end

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

    TriggerServerEvent('dragCraft:success', result, recipe)

    if result then
        if recipe.client?.after then
            recipe.client.after(recipe)
        end
    end
end)

local function addRecipe(id, recipe, sync)
    recipe.server = nil
    RECIPES[id] = recipe

    if sync then return end

    lib.callback.await('dragCraft:server:addRecipe', false, id, recipe, true)
end

lib.callback.register('dragCraft:client:addRecipe', addRecipe)
exports('addRecipe', addRecipe)
