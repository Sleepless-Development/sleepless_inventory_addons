local ox_inventory = exports.ox_inventory

local CraftQueue = {}

local craftHook = ox_inventory:registerHook('swapItems', function(data)
    local fromSlot = data.fromSlot
    local toSlot = data.toSlot

    if type(fromSlot) == "table" and type(toSlot) == "table" then
        if fromSlot.name == toSlot.name then return end

        local recipeIndex = (RECIPES[fromSlot.name .. " " .. toSlot.name] and fromSlot.name .. " " .. toSlot.name) or (RECIPES[toSlot.name .. " " .. fromSlot.name] and toSlot.name .. " " .. fromSlot.name) or nil

        if not recipeIndex then return end

        local recipe = RECIPES[recipeIndex]

        local amount1 = recipe.costs[fromSlot.name].need
        if amount1 > ox_inventory:GetItem(data.source, fromSlot.name, nil, true) then
            local description = ("Not enough %s. Need %d"):format(fromSlot.label, recipe.costs[fromSlot.name])
            TriggerClientEvent('ox_lib:notify', data.source, { type = 'error', description = description })
            return false
        end

        local amount2 = recipe.costs[toSlot.name].need
        if amount2 > ox_inventory:GetItem(data.source, toSlot.name, nil, true) then
            local description = ("Not enough %s. Need %d"):format(toSlot.label, recipe.costs[toSlot.name])
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
                remove = recipe.costs[fromSlot.name].remove
            },
            item2 = {
                name = toSlot.name,
                amount = amount2,
                remove = recipe.costs[toSlot.name].remove
            },
            result = resultForQueue
        }

        TriggerClientEvent('demi-dragCraft:Craft', data.source, recipe.duration)

        return false
    end
end, {})




lib.callback.register('demi-dragCraft:success', function(source, success)
    local queuedCraft = CraftQueue[source]

    if not queuedCraft then return end

    if success then
        if queuedCraft.item1.remove then
            ox_inventory:RemoveItem(source, queuedCraft.item1.name, queuedCraft.item1.amount)
        end
        if queuedCraft.item2.remove then
            ox_inventory:RemoveItem(source, queuedCraft.item2.name, queuedCraft.item2.amount)
        end
        for i = 1, #queuedCraft.result do
            local resultData = queuedCraft.result[i]
            ox_inventory:AddItem(source, resultData.name, resultData.amount)
        end
    end

    CraftQueue[source] = nil
end)
