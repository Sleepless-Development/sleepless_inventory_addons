local CBackItem = require 'backItems.imports.backitem'
local CBackWeapon = require 'backItems.imports.weapon'
local Utils = require 'backItems.imports.utils'
local PlayerState = LocalPlayer.state

SetFlashLightKeepOnWhileMoving(true)

local Players = {}

local function deleteBackItemsForPlayer(serverId)
    if not serverId or not Players[serverId] then return end

    for i = 1, #Players[serverId] do
        local backItem = Players[serverId][i]

        if backItem then
            backItem:destroy()
        end
    end

    table.wipe(Players[serverId])
end

local Inventory = exports.ox_inventory;
local function createBackItemsForPlayer(serverId, backItems)
    for i = 1, #backItems do
        local itemData = backItems[i];
        local itemCount = Inventory:GetItemCount(itemData.name);

        if itemCount and itemCount > 0 then
            if itemData.isWeapon then
                Players[serverId][#Players[serverId] + 1] = CBackWeapon:new(serverId, itemData)
            else
                Players[serverId][#Players[serverId] + 1] = CBackItem:new(serverId, itemData)
            end
        end
    end
end

local function refreshBackItemsLocal()
    local serverId = cache.serverId
    if Players[serverId] then
        deleteBackItemsForPlayer(serverId)

        local Items = Utils.formatCachedInventory(InvCache)

        createBackItemsForPlayer(serverId, Items)
    end
end

function RefreshBackItems()
    if not Players[cache.serverId] then
        Players[cache.serverId] = {}
    end
    if PlayerState.backItems and next(PlayerState.backItems) then
        PlayerState:set('backItems', false, true)

        UpdateBackItems()
    end
end

AddStateBagChangeHandler('bucket', ('player:%s'):format(cache.serverId), function(_, _, value)
    if value == 0 then
        if PlayerState.backItems and next(PlayerState.backItems) then
            refreshBackItemsLocal()
        end
    end
end)

RegisterNetEvent('txcl:setPlayerMode', function(mode)
    if mode == "noclip" then
        PlayerState:set("hideAllBackItems", true, true)
    elseif mode == "none" then
        PlayerState:set("hideAllBackItems", false, true)
    end

    RefreshBackItems()
end)

AddStateBagChangeHandler('backItems', nil, function(bagName, _, backItems, _, replicated)
    if replicated then
        return
    end

    local playerId = GetPlayerFromStateBagName(bagName)
    local serverId = GetPlayerServerId(playerId)

    if not Players[serverId] then
        Players[serverId] = {}
    end

    if not backItems then
        return deleteBackItemsForPlayer(serverId)
    end

    local plyPed = playerId == cache.playerId and cache.ped or lib.waitFor(function()
        local ped = GetPlayerPed(playerId)
        if ped > 0 then return ped end
    end, ('%s Player didnt exsist in time! (%s)'):format(playerId, bagName), 10000)

    if not plyPed or plyPed == 0 then return end

    deleteBackItemsForPlayer(serverId)

    if next(backItems) then
        createBackItemsForPlayer(serverId, backItems)
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for serverId, backItems in pairs(Players) do
            if backItems then
                deleteBackItemsForPlayer(serverId)
            end
        end
    end
end)

CreateThread(function()
    while not LocalPlayer.state.isLoggedIn do Wait(100) end

    while true do
        Wait(1000)
        for serverId, backItems in pairs(Players) do
            local targetPed = GetPlayerPed(GetPlayerFromServerId(serverId))
            if targetPed and DoesEntityExist(targetPed) then
                for i = 1, #backItems do
                    local backItem = backItems[i]
                    if backItem and not IsEntityAttachedToEntity(backItem.object, targetPed) then
                        backItem:attach()
                    end
                end
            else
                deleteBackItemsForPlayer(serverId)
            end
        end
    end
end)

RegisterNetEvent('backItems:clearPlayerItems', function(serverId)
    deleteBackItemsForPlayer(serverId)
    Players[serverId] = nil
end)
