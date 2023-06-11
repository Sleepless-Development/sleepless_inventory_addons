local ox_inventory = exports.ox_inventory

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
        Wait(500) --wait for inventory to update after whatever hook
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

        playerState:set("backItems", newBackItems, true)

    end)
end

local swapSlingHook = ox_inventory:registerHook('swapItems', function(payload)
    if not (type(payload.fromSlot) == "table" and BACK_ITEMS[payload.fromSlot.name] or type(payload.toSlot) == "table" and BACK_ITEMS[payload.toSlot.name]) or not (payload.fromInventory == payload.source or payload.toInventory == payload.source) then return end

    generateNewBackItems(payload.source)

end, {})


RegisterNetEvent("backItems:loadForSpawn", function()
    local source = source --[[@as number]]

    generateNewBackItems(source)

end)



local createSlingHook = ox_inventory:registerHook('createItem', function(payload)
    local plyid = type(payload.inventoryId) == "number" and payload.inventoryId

    if not BACK_ITEMS[payload.item.name] or not plyid then return end

    generateNewBackItems(plyid)

end, {})