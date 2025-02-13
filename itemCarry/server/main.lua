local ox_inventory = exports.ox_inventory
local CARRY_ITEMS = require 'itemCarry.config'

ox_inventory:registerHook('createItem', function(payload)
    local carryData = CARRY_ITEMS[payload?.item?.name]
    local plyid = type(payload.inventoryId) == "number" and payload.inventoryId

    if not carryData or not plyid then return end

    local plyState = Player(plyid).state

    if plyState.carryItem then
        lib.notify(plyid, {
            title = 'Inventory',
            description = 'You are already carrying something!',
            type = 'error'
        })
        local coords = GetEntityCoords(GetPlayerPed(plyid))
        CreateThread(function()
            Wait(300)
            local success = ox_inventory:RemoveItem(plyid, payload?.item?.name, payload?.count, payload?.metadata)
            if success then
                ox_inventory:CustomDrop(payload?.item?.label,
                    { { payload?.item?.name, payload?.count, payload?.metadata } },
                    coords, 1, nil, nil, carryData.prop.model)
            end
        end)
    end
end, {})

ox_inventory:registerHook('swapItems', function(payload)
    if payload.toInventory ~= payload.fromInventory then
        local isCarryItem = false

        if payload.toInventory == payload.source then
            local item = payload.fromSlot

            if type(item) == 'table' and CARRY_ITEMS[item.name] then
                isCarryItem = true
            end
        elseif payload.fromInventory == payload.source then
            local item = payload.toSlot

            if type(item) == 'table' and CARRY_ITEMS[item.name] then
                isCarryItem = true
            end
        end

        if isCarryItem then
            local plyState = Player(payload.source).state

            if plyState.carryItem then
                lib.notify(payload.source, {
                    title = 'Inventory',
                    description = 'You are already carrying something!',
                    type = 'error'
                })
                return false
            end
        end
    end
end, {})

exports.ox_inventory:registerHook('swapItems', function(payload)
    local droppedItem   = payload.fromSlot
    local carryData     = CARRY_ITEMS[droppedItem.name]
    local itemCarryDrop = { [droppedItem.name] = { count = droppedItem.count } }
    
    if payload.toInventory ~= 'newdrop' or not itemCarryDrop then 
        return 
    end

    local item = payload.fromSlot
    local items = { { item.name, payload.count, item.metadata } }
    
    if carryData == nil then 
        return 
    end
    
    if droppedItem and type(droppedItem) == 'table' then
        local dropId = exports.ox_inventory:CustomDrop(
            item.label, 
            items,
            GetEntityCoords(GetPlayerPed(payload.source)), 
            1, 
            1,  -- weight set to 1 since when removing the item from the custom drop and switch it with a item that has less weight, the prop stays but the item is different
            nil, 
            carryData.prop.model
        )
        
        if not dropId then 
            return 
        end

        CreateThread(function()
            exports.ox_inventory:RemoveItem(payload.source, item.name, payload.count, nil, item.slot)
            Wait(0)
            exports.ox_inventory:forceOpenInventory(payload.source, 'drop', dropId)
        end)
    end

    return false
end, {
    itemFilter = itemCarryDrop,
    typeFilter = { player = true }
})

local function findCarryItem(source)
    local playerState = Player(source).state
    playerState:set("carryItem", nil, true)

    local playerItems = exports.ox_inventory:GetInventoryItems(source)

    if not playerItems then return end

    for _, itemData in pairs(playerItems) do
        if itemData and CARRY_ITEMS[itemData.name] then
            playerState:set("carryItem", itemData.name, true)
            return
        end
    end
end

CreateThread(function()
    Wait(500)
    for _, serverId in ipairs(GetPlayers()) do
        findCarryItem(tonumber(serverId))
    end
end)


RegisterNetEvent("carryItem:updateCarryItem", function(item, amount)
    local plyState = Player(source).state

    plyState:set("carryItem", (amount > 0 and item) or nil, true)
end)
