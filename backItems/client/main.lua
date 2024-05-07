local CBackItem = require 'backItems.imports.backitem'
local CBackWeapon = require 'backItems.imports.weapon'
local Utils = require 'backItems.imports.utils'
local PlayerState = LocalPlayer.state

SetFlashLightKeepOnWhileMoving(true)

local Players = {}

local function deleteBackItemsForPlayer(playerId)
    if not Players[playerId] then return end

    for i = 1, #Players[playerId] do
        local backItem = Players[playerId][i]

        if backItem then
            backItem:destroy()
            Players[playerId][i] = nil
        end
    end
end

local function removePlayerFromList(playerId)
    if not playerId or not Players[playerId] then return end

    deleteBackItemsForPlayer(playerId)
    Players[playerId] = {}
end

local function createBackItemsForPlayer(playerId, backItems)
    for i = 1, #backItems do
        local itemData = backItems[i]
        if itemData.isWeapon then
            Players[playerId][#Players[playerId] + 1] = CBackWeapon:new(playerId, itemData)
        else
            Players[playerId][#Players[playerId] + 1] = CBackItem:new(playerId, itemData)
        end
    end
end

local function refreshBackItemsLocal()
    local playerId = cache.playerId
    if Players[playerId] then
        deleteBackItemsForPlayer(playerId)

        Players[playerId] = {}

        local Items = Utils.formatCachedInventory(InvCache)

        createBackItemsForPlayer(playerId, Items)
    end
end

function RefreshBackItems()
    if PlayerState.backItems and next(PlayerState.backItems) then
        PlayerState:set('backItems', false, true)

        UpdateBackItems()
    end
end

RegisterCommand('testBucket', function()
    PlayerState:set("bucket", 0)
end)

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

    if not backItems then
        return removePlayerFromList(playerId)
    end

    local plyPed = playerId == cache.playerId and cache.ped or lib.waitFor(function()
        local ped = GetPlayerPed(playerId)
        if ped > 0 then return ped end
    end, ('%s Player didnt exsist in time! (%s)'):format(playerId, bagName), 10000)

    if not plyPed or plyPed == 0 then return end

    deleteBackItemsForPlayer(playerId)

    Players[playerId] = {}

    if next(backItems) then
        createBackItemsForPlayer(playerId, backItems)
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for playerId, backItems in pairs(Players) do
            if backItems then
                deleteBackItemsForPlayer(playerId)
            end
        end
    end
end)


CreateThread(function()
    local NetworkIsPlayerActive = NetworkIsPlayerActive

    while true do
        for playerId, weapons in pairs(Players) do
            if weapons and next(weapons) and not NetworkIsPlayerActive(playerId) then
                removePlayerFromList(playerId)
            end
        end
        Wait(1000)
    end
end)
