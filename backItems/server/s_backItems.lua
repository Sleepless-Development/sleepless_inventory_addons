local function getPotentialBackItems(playerItems)
    local potentialBackItems = {}
    for _, item in pairs(playerItems) do
        if item and BACK_ITEMS[item.name] then
            local index = #potentialBackItems + 1
            potentialBackItems[index] = lib.table.deepclone(BACK_ITEMS[item.name])
            potentialBackItems[index].slot = item.slot
            potentialBackItems[index].name = item.name
            potentialBackItems[index].attachments = item?.metadata?.components or {}
        end
    end
    return potentialBackItems
end

local function generateNewBackItems(source)
    CreateThread(function ()
        local playerState = Player(source).state
        local playerItems = exports.ox_inventory:GetInventoryItems(source)
        local newBackItems = {}

        local potentialBackItems = getPotentialBackItems(playerItems)

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
                    print(("[ERROR]: ignore limits was set for %s, but customPos was nil."):format(potentialBackItems[i].name))
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

RegisterNetEvent("backItems:onUpdateInventory", function()
    generateNewBackItems(source)
end)