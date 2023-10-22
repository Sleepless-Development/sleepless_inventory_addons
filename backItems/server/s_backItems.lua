local function getPotentialBackItems(source, playerItems, hideall, weapon)
    if type(playerItems) ~= "table" then return {} end
    local potentialBackItems = {}
    Wait(300)
    local currentWeapon = exports.ox_inventory:GetCurrentWeapon(source)
    print(source)
    print(json.encode(currentWeapon, { indent = true }))

    for _, item in pairs(playerItems) do
        if item and BACK_ITEMS[item.name] then
            local index = #potentialBackItems + 1
            potentialBackItems[index] = lib.table.deepclone(BACK_ITEMS[item.name])
            potentialBackItems[index].slot = item.slot
            potentialBackItems[index].name = item.name
            potentialBackItems[index].attachments = item?.metadata?.components or {}

            local visible = true
            print('hideall', hideall)
            print('visible', not currentWeapon.slot == item.slot, currentWeapon.slot, item.slot)
            if (hideall ~= nil and hideall or weapon and currentWeapon?.slot == item?.slot) then
                visible = false
            end
            potentialBackItems[index].visible = visible
        end
    end
    print(json.encode(potentialBackItems, { indent = true }))
    return potentialBackItems
end

local function generateNewBackItems(source, weapon)
    CreateThread(function()
        local playerState = Player(source).state
        local playerItems = exports.ox_inventory:GetInventoryItems(source)
        local newBackItems = {}

        local potentialBackItems = getPotentialBackItems(source, playerItems, playerState.hideAllBackItems, weapon)

        if #potentialBackItems > 1 then
            table.sort(potentialBackItems, function(a, b)
                return a.prio > b.prio
            end)
        end

        local numberOfFoundItems = 0

        for i = 1, #potentialBackItems do
            if potentialBackItems[i] and not potentialBackItems[i].ignoreLimits and numberOfFoundItems < BACK_ITEM_LIMIT then
                numberOfFoundItems += 1
                newBackItems[numberOfFoundItems] = potentialBackItems[i]
            end
        end

        for i = 1, #potentialBackItems do
            local backItemData = potentialBackItems[i]
            if backItemData.ignoreLimits then
                if backItemData.customPos then
                    potentialBackItems[i].prio = -1
                    table.insert(newBackItems, backItemData)
                else
                    print(("[ERROR]: ignore limits was set for %s, but customPos was nil."):format(potentialBackItems[i]
                        .name))
                end
            end
        end

        print('setting backItems state for serverId', source)
        playerState:set("backItems", newBackItems, true)
    end)
end

AddEventHandler("playerDropped", function()
    local source = source
    TriggerClientEvent("backItems:RemoveItemsOnDropped", -1, source)
end)

RegisterNetEvent("backItems:onUpdateInventory", function(weapon)
    generateNewBackItems(source, weapon)
end)
