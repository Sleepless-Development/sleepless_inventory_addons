---@class CraftItem
---@field name string The name of the item.
---@field amount number The amount of the item involved in the craft.
---@field remove boolean Whether the item should be removed after the crafting process.
---@field slot number The slot number of the item in the inventory.

---@class CraftResult
---@field name string The name of the resulting item.
---@field amount number The amount of the resulting item.
---@field metadata? table The metadata for the resulting item.

---@class CraftQueueEntry
---@field recipeIndex string
---@field item1 CraftItem Information about the first item used in crafting.
---@field item2 CraftItem Information about the second item used in crafting.
---@field result CraftResult[] The result of the crafting process.
---@field startedAt number GetGameTimer() when the craft was queued
---@field duration number ms the client is expected to take
---@field expiresAt number GetGameTimer() when this craft attempt expires

local ox_inventory = exports.ox_inventory
local RECIPES = require 'dragCraft.config'

---@type table<number, CraftQueueEntry>
local CraftQueue = {}

local CRAFT_GRACE_MS = 5000
local CRAFT_EARLY_TOLERANCE_MS = 250

local craftHook = ox_inventory:registerHook('swapItems', function(data)
    local fromSlot = data.fromSlot
    local toSlot = data.toSlot

    if type(fromSlot) == "table" and type(toSlot) == "table" then
        if fromSlot.name == toSlot.name then return end

        local existing = CraftQueue[data.source]
        if existing then
            if existing.expiresAt and GetGameTimer() > existing.expiresAt then
                CraftQueue[data.source] = nil
            else
                return false
            end
        end

        local recipeKey = string.format("%s %s", fromSlot.name, toSlot.name)
        local reverseRecipeKey = string.format("%s %s", toSlot.name, fromSlot.name)
        local recipeIndex = (RECIPES[recipeKey] and recipeKey) or (RECIPES[reverseRecipeKey] and reverseRecipeKey) or nil

        if not recipeIndex then return end

        local recipe = RECIPES[recipeIndex]
        if not recipe or type(recipe.costs) ~= 'table' or type(recipe.result) ~= 'table' then return end
        if not recipe.costs[fromSlot.name] or not recipe.costs[toSlot.name] then return end

        local amount1 = recipe.costs[fromSlot.name].need
        if type(amount1) ~= 'number' or amount1 <= 0 or amount1 > fromSlot.count then
            local description = ("Not enough %s. Need %d"):format(fromSlot.label, amount1 or 0)
            TriggerClientEvent('ox_lib:notify', data.source, { type = 'error', description = description })
            return false
        end

        local amount2 = recipe.costs[toSlot.name].need
        if type(amount2) ~= 'number' or amount2 <= 0 or amount2 > toSlot.count then
            local description = ("Not enough %s. Need %d"):format(toSlot.label, amount2 or 0)
            TriggerClientEvent('ox_lib:notify', data.source, { type = 'error', description = description })
            return false
        end

        local resultForQueue = {}

        for i = 1, #recipe.result do
            local resultData = recipe.result[i]
            if type(resultData) ~= 'table' or type(resultData.name) ~= 'string' then return false end

            local amount = (resultData.min and resultData.max and math.random(resultData.min, resultData.max))
                or resultData.amount
                or 1

            if type(amount) ~= 'number' or amount < 1 then amount = 1 end
            amount = math.floor(amount)

            resultForQueue[i] = {
                name = resultData.name,
                amount = amount,
                metadata = recipe.server?.metadata and recipe.server.metadata(resultData.name, fromSlot, toSlot) or nil
            }
        end

        local duration = tonumber(recipe.duration) or 0
        local startedAt = GetGameTimer()

        CraftQueue[data.source] = {
            recipeIndex = recipeIndex,
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
            result = resultForQueue,
            startedAt = startedAt,
            duration = duration,
            expiresAt = startedAt + duration + CRAFT_GRACE_MS,
        }

        ---@type boolean | nil
        local continue = nil

        if recipe.server?.before then
            continue = recipe.server.before(recipe)
        end

        if continue == false then
            CraftQueue[data.source] = nil
            return false
        end

        TriggerClientEvent('dragCraft:Craft', data.source, duration, recipeIndex)

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
        ox_inventory:RemoveItem(source, craftItem.name, craftItem.amount, nil, craftItem.slot)
    end
end

---@param source number
---@param craftItem CraftItem
---@return boolean
local function slotStillValid(source, craftItem)
    local slot = ox_inventory:GetSlot(source, craftItem.slot)
    if not slot or slot.name ~= craftItem.name then return false end
    if craftItem.amount >= 1 and (slot.count or 0) < craftItem.amount then return false end
    return true
end

RegisterNetEvent('dragCraft:success', function(success)
    local source = source --[[@as number]]
    local queuedCraft = CraftQueue[source]
    if not queuedCraft then return end

    CraftQueue[source] = nil

    if success ~= true then return end

    local now = GetGameTimer()
    if now > queuedCraft.expiresAt then return end
    if now + CRAFT_EARLY_TOLERANCE_MS < queuedCraft.startedAt + queuedCraft.duration then return end

    local recipe = RECIPES[queuedCraft.recipeIndex]
    if not recipe then return end

    if not slotStillValid(source, queuedCraft.item1) then return end
    if not slotStillValid(source, queuedCraft.item2) then return end

    processCraftItem(source, queuedCraft.item1)
    processCraftItem(source, queuedCraft.item2)

    for i = 1, #queuedCraft.result do
        local resultData = queuedCraft.result[i]
        ox_inventory:AddItem(source, resultData.name, resultData.amount, resultData.metadata)
    end

    if recipe.server?.after then
        recipe.server.after(recipe)
    end
end)

AddEventHandler('playerDropped', function()
    CraftQueue[source] = nil
end)

---@type table<string, table>
local runtimeRecipes = {}

---@param recipe CraftRecipe
---@return table
local function getSyncableRecipe(recipe)
    local payload = {}

    for key, value in pairs(recipe) do
        if key ~= 'server' and key ~= 'client' and type(value) ~= 'function' then
            payload[key] = value
        end
    end

    return payload
end

---Server-only recipe registration. Never expose as a net callback.
---@param id string
---@param recipe CraftRecipe
---@param target? number specific player to sync UI, or nil for all players
---@return boolean
local function addRecipe(id, recipe, target)
    if GetInvokingResource() == nil then
        return false
    end

    if type(id) ~= 'string' or type(recipe) ~= 'table' then
        return false
    end

    local existing = RECIPES[id] or {}

    local stored = {
        duration = recipe.duration or existing.duration,
        costs = recipe.costs or existing.costs,
        result = recipe.result or existing.result,
        server = recipe.server or existing.server,
    }

    if type(stored.costs) ~= 'table' or type(stored.result) ~= 'table' then
        return false
    end

    for key, value in pairs(recipe) do
        if stored[key] == nil and key ~= 'client' and type(value) ~= 'function' then
            stored[key] = value
        end
    end

    RECIPES[id] = stored

    local payload = getSyncableRecipe(stored)
    runtimeRecipes[id] = payload

    if target and type(target) == 'number' then
        TriggerClientEvent('dragCraft:syncRecipe', target, id, payload)
    else
        TriggerClientEvent('dragCraft:syncRecipe', -1, id, payload)
    end

    return true
end

lib.callback.register('dragCraft:getRuntimeRecipes', function()
    return runtimeRecipes
end)

exports('addRecipe', addRecipe)
