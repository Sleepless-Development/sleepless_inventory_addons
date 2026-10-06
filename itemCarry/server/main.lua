local ox_inventory = exports.ox_inventory
local CARRY_ITEMS = require 'itemCarry.config'

local carryItemFilter = {}

for itemName in pairs(CARRY_ITEMS) do
    carryItemFilter[itemName] = true
end

local rejectedCarryCreates = setmetatable({}, { __mode = 'k' })

local function rejectIfAlreadyCarrying(payload)
    local playerId = type(payload.inventoryId) == 'number' and payload.inventoryId

    if not playerId then return end
    if not Player(playerId).state.carryItem then return end

    rejectedCarryCreates[payload] = playerId
end

local function dropRejectedCarryItem(success, payload)
    local playerId = rejectedCarryCreates[payload]
    rejectedCarryCreates[payload] = nil

    if not success or not playerId then return end

    local item = payload.item
    local carryData = item and CARRY_ITEMS[item.name]

    if not carryData then return end

    local ped = GetPlayerPed(playerId)

    if ped == 0 then return end

    local removed = ox_inventory:RemoveItem(playerId, item.name, payload.count, payload.metadata)

    if not removed then return end

    lib.notify(playerId, {
        title = 'Inventory',
        description = 'You are already carrying something!',
        type = 'error'
    })

    ox_inventory:CustomDrop(item.label, {
        { item.name, payload.count, payload.metadata }
    }, GetEntityCoords(ped), 1, nil, nil, carryData.prop.model)
end

local createCarryItemHook = ox_inventory:registerHook('createItem', rejectIfAlreadyCarrying, {
    itemFilter = carryItemFilter,
})

AddEventHandler(createCarryItemHook, dropRejectedCarryItem)

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
