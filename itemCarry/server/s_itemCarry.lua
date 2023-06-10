local ox_inventory = exports.ox_inventory

local swapCarryHook = ox_inventory:registerHook('swapItems', function(payload)
    local carryData = CARRY_ITEMS[payload?.fromSlot?.name]
    if not carryData or payload.toInventory == payload.fromInventory then return end

    local plyState = Player(payload.source).state
    local removed = payload.fromInventory == payload.source and payload.toInventory ~= payload.source

    if removed then
        if ox_inventory:GetItemCount(payload.source, payload?.fromSlot?.name) - payload.count <= 0 then
            plyState:set("carryItem", nil, true)
        end
    else
        if plyState.carryItem then
            lib.notify(payload.source, {
                title = 'Inventory',
                description = 'You are already carrying something!',
                type = 'error'
            })
             return false
        end

        plyState:set("carryItem", carryData, true)
    end

end, {})

local createCarryHook = ox_inventory:registerHook('createItem', function(payload)
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
                ox_inventory:CustomDrop(payload?.item?.label, {{payload?.item?.name, payload?.count, payload?.metadata}}, coords, 1, nil, nil, carryData.prop.model)
            end
        end)
    else
        plyState:set("carryItem", carryData, true)
    end

end, {})

local function findCarryItem(source)
    CreateThread(function ()
        Wait(500) --wait for inventory to update after whatever hook
        local playerState = Player(source).state
        local playerItems = exports.ox_inventory:GetInventoryItems(source)
        local carryData = nil

        for i = 1, #playerItems do
            local itemData = playerItems[i]
            if CARRY_ITEMS[itemData.name] then
                carryData = CARRY_ITEMS[itemData.name]
                break
            end
        end


        plyState:set("carryItem", carryData, true)

    end)
end


RegisterNetEvent("carryItem:loadForSpawn", function()
    local source = source
    findCarryItem(source)
end)