---@class CraftItem
---@field name string The name of the item.
---@field amount number The amount of the item involved in the craft.
---@field remove boolean Whether the item should be removed after the crafting process.
---@field slot number The slot number of the item in the inventory.

---@class CraftResult
---@field name string The name of the resulting item.
---@field amount number The amount of the resulting item.

---@class CraftQueueEntry
---@field item1 CraftItem Information about the first item used in crafting.
---@field item2 CraftItem Information about the second item used in crafting.
---@field result CraftResult[] The result of the crafting process.

local ox_inventory = exports.ox_inventory
local RECIPES = require 'dragCraft.config'

---@type table<number, CraftQueueEntry>
local CraftQueue = {}

local craftHook = ox_inventory:registerHook('swapItems', function(data)
    local fromSlot = data.fromSlot
    local toSlot = data.toSlot

    if type(fromSlot) == "table" and type(toSlot) == "table" then

        if fromSlot.name == toSlot.name then return end

        local recipeKey = string.format("%s %s", fromSlot.name, toSlot.name)
        local reverseRecipeKey = string.format("%s %s", toSlot.name, fromSlot.name)
        local recipeIndex = (RECIPES[recipeKey] and recipeKey) or (RECIPES[reverseRecipeKey] and reverseRecipeKey) or nil

        if not recipeIndex then return end

        local recipe = RECIPES[recipeIndex]

        local amount1 = recipe.costs[fromSlot.name].need
        if amount1 > ox_inventory:GetItem(data.source, fromSlot.name, nil, true) then
            local description = ("Not enough %s. Need %d"):format(fromSlot.label, amount1)
            TriggerClientEvent('ox_lib:notify', data.source, { type = 'error', description = description })
            return false
        end

        local amount2 = recipe.costs[toSlot.name].need
        if amount2 > ox_inventory:GetItem(data.source, toSlot.name, nil, true) then
            local description = ("Not enough %s. Need %d"):format(toSlot.label, amount2)
            TriggerClientEvent('ox_lib:notify', data.source, { type = 'error', description = description })
            return false
        end

        local resultForQueue = {}

        for i = 1, #recipe.result do
            local resultData = recipe.result[i]
            resultForQueue[i] = {
                name = resultData.name,
                amount = resultData.amount
            }
        end

        CraftQueue[data.source] = {
            item1 = {
                name = fromSlot.name,
                amount = amount1,
                remove = recipe.costs[fromSlot.name].remove,
                slot = fromSlot.slot
            },
            item2 = {
                name = toSlot.name,
                amount = amount2,
                remove = recipe.costs[toSlot.name].remove,
                slot = toSlot.slot
            },
            result = resultForQueue
        }

        ---@type boolean | nil
        local continue = nil

        if recipe.server?.before then
            continue = recipe.server.before(recipe)
        end

        if continue == false then return false end

        TriggerClientEvent('dragCraft:Craft', data.source, recipe.duration, recipeIndex)

        return false
    end
end, {})

---@param source number player server id
---@param craftItem CraftItem
local function updateItemDurability(source, craftItem)
    local item = ox_inventory:GetSlot(source, craftItem.slot)
    if not item then return end

    local durability = item.metadata?.durability or 100
    durability = durability - (100 * craftItem.amount)

    if durability <= 0 then
        ox_inventory:RemoveItem(source, craftItem.name, 1, nil, item.slot)
    else
        ox_inventory:SetDurability(source, item.slot, durability)
    end
end

---@param source number player server id
---@param craftItem CraftItem
local function processCraftItem(source, craftItem)
    if not craftItem.remove then return end

    if craftItem.amount > 0 and craftItem.amount < 1 then
        updateItemDurability(source, craftItem)
    else
        ox_inventory:RemoveItem(source, craftItem.name, craftItem.amount)
    end
end

---@param success boolean
---@param recipe CraftRecipe
RegisterNetEvent('dragCraft:success', function(success, recipe)
    local source = source --[[@as number]]
    local queuedCraft = CraftQueue[source]
    if not queuedCraft then return end

    if success then
        processCraftItem(source, queuedCraft.item1)
        processCraftItem(source, queuedCraft.item2)

        for i = 1, #queuedCraft.result do
            local resultData = queuedCraft.result[i]
            ox_inventory:AddItem(source, resultData.name, resultData.amount)
        end

        if recipe.server?.after then
            recipe.server?.after(recipe)
        end
    end

    CraftQueue[source] = nil
end)


local function addRecipe(source, id, recipe, sync)
    recipe.client = nil
    RECIPES[id] = recipe

    if sync then return end

    lib.callback.await('dragCraft:client:addRecipe', source, id, recipe, true)
end

lib.callback.register('dragCraft:server:addRecipe', addRecipe)
exports('addRecipe', addRecipe)
