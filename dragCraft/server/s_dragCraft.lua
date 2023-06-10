local ox_inventory = exports.ox_inventory

local CraftQueue = {}

local craftHook = ox_inventory:registerHook('swapItems', function(data)
    local fromSlot = data.fromSlot
    local toSlot = data.toSlot

    if type(fromSlot) == "table" and type(toSlot) == "table" then
        if fromSlot.name == toSlot.name then return end

        local item1 = (RECIPES[fromSlot.name] and fromSlot) or (RECIPES[toSlot.name] and toSlot)
        if not item1 then return end

        local amount1 = RECIPES[item1.name].costs[item1.name].need
        if amount1 > ox_inventory:GetItem(data.source, item1.name, nil, true) then
            local description = ("Not enough %s. Need %d"):format(item1.label, RECIPES[item1.name].costs[item1.name])
            TriggerClientEvent('ox_lib:notify', data.source, { type = 'error', description = description })
            return false
        end

        local otherItem = RECIPES[item1.name].otherItem
        local item2 = (otherItem == fromSlot.name and fromSlot) or (otherItem == toSlot.name and toSlot)
        if not item2 then return end

        local amount2 = RECIPES[item1.name].costs[item2.name].need
        if amount2 > ox_inventory:GetItem(data.source, item2.name, nil, true) then
            local description = ("Not enough %s. Need %d"):format(item2.label, RECIPES[item1.name].costs[item2.name])
            TriggerClientEvent('ox_lib:notify', data.source, { type = 'error', description = description })
            return false
        end

        local duration = RECIPES[item1.name].duration
        TriggerClientEvent('demi-dragCraft:Craft', data.source, duration)

        local resultItems = RECIPES[item1.name].result

        local resultForQueue = {}

        for i = 1, #resultItems do
            local resultData = resultItems[i]
            resultForQueue[i] = {
                name = resultData.name,
                amount = resultData.amount
            }
        end

        CraftQueue[data.source] = {
            item1 = {
                name = item1.name,
                amount = amount1,
                remove = RECIPES[item1.name].costs[item1.name].remove
            },
            item2 = {
                name = item2.name,
                amount = amount2,
                remove = RECIPES[item1.name].costs[item2.name].remove
            },
            result = resultForQueue
        }

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
