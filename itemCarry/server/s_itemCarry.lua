local ox_inventory = exports.ox_inventory

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
                ox_inventory:CustomDrop(payload?.item?.label, {{payload?.item?.name, payload?.count, payload?.metadata}}, coords, 1, nil, nil, carryData.prop.model)
            end
        end)
    end

end, {})

ox_inventory:registerHook('swapItems', function(payload)
    if payload.toInventory ~= payload.fromInventory and payload.toInventory == payload.source then
        local item = payload.fromSlot
        local carryData = CARRY_ITEMS[item.name]

        if carryData then
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

local function findCarryItem(source)
    CreateThread(function ()
        Wait(500) --wait for inventory to update after whatever hook
        local playerState = Player(source).state
        local playerItems = exports.ox_inventory:GetInventoryItems(source)
        local carryData = nil

        for i, v in pairs(playerItems) do
            local itemData = v
            if itemData and CARRY_ITEMS[itemData.name] then
                carryData = CARRY_ITEMS[itemData.name]
                break
            end
        end

        playerState:set("carryItem", carryData, true)

    end)
end


RegisterNetEvent("carryItem:onUpdateInventory", function()
    findCarryItem(source)
end)