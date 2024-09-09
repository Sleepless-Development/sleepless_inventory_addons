local Players = {};
local isCarrying = false;
local CARRY_DATA <const> = require 'itemCarry.config';

exports('isCarryingObject', function()
    return isCarrying
end)
local function onLoad()
    LocalPlayer.state:set('carryItem', nil, true);

    local playerItems = exports.ox_inventory:GetPlayerItems();
    local carryItem = nil;

    for i, v in pairs(playerItems) do
        local itemData = v;
        if itemData and CARRY_DATA[itemData.name] then
            carryItem = itemData.name;
            break;
        end
    end

    LocalPlayer.state:set('carryItem', carryItem, true);
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', onLoad)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == cache.resource then
        for serverId, carryItem in pairs(Players) do
            if carryItem and DoesEntityExist(carryItem) then
                deleteCarryItemForPlayer(serverId)
            end
        end
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == cache.resource then
        return onLoad()
    end
end)

AddStateBagChangeHandler('carryItem', nil, function(bagName, key, carryItem, _unused, replicated)
    local playerIdx = GetPlayerFromStateBagName(bagName);

    if playerIdx == 0 or playerIdx == -1 then
        return
    end

    local serverId = GetPlayerServerId(playerIdx);

    if not carryItem then
        return deleteCarryItemForPlayer(serverId)
    end

    local plyPed = playerIdx == cache.playerId and cache.ped or lib.waitFor(function()
        local ped = GetPlayerPed(playerIdx)
        if ped > 0 then return ped end
    end, ('%s Player didnt exsist in time! (%s)'):format(playerIdx, bagName), 15000)

    if not plyPed or plyPed == 0 then return end

    if playerIdx == cache.playerId then
        startCarryingObject(carryItem)
    else
        deleteCarryItemForPlayer(serverId)
        createCarryItemForPlayer(serverId, carryItem)
    end
end)

function deleteCarryItemForPlayer(serverId)
    if not Players[serverId] then return end

    local currentCarryObject = Players[serverId];
    if currentCarryObject and DoesEntityExist(currentCarryObject) then
        DeleteEntity(currentCarryObject); Players[serverId] = nil;
    end

    if cache.serverId == serverId then
        ClearPedTasks(cache.ped); isCarrying = false;
    end

    return true;
end

function createCarryItemForPlayer(serverId, itemName)
    if Players[serverId] then return end

    local itemData = CARRY_DATA[itemName];
    if not itemData then return end

    local targetPed = GetPlayerPed(GetPlayerFromServerId(serverId))

    lib.requestModel(itemData.prop.model)

    local plyPos = GetEntityCoords(targetPed)
    lib.requestModel(itemData.prop.model, 1000)
    local currentCarryObject = CreateObject(itemData.prop.model, plyPos.x, plyPos.y, plyPos.z + 0.2, false, false, false)
    SetEntityCollision(currentCarryObject, false, false)

    local placement = itemData.prop.placement

    AttachEntityToEntity(
        currentCarryObject,
        targetPed,
        GetPedBoneIndex(targetPed, itemData.prop.bone),
        placement.pos.x,
        placement.pos.y,
        placement.pos.z,
        placement.rot.x,
        placement.rot.y,
        placement.rot.z,
        true,
        true,
        false,
        true,
        1,
        true
    )

    Players[serverId] = currentCarryObject

    return currentCarryObject
end

function startCarryingObject(itemName)
    if isCarrying then return end

    local itemData = CARRY_DATA[itemName];
    if not itemData then return end

    local currentCarryObject = createCarryItemForPlayer(cache.serverId, itemName);
    if not currentCarryObject then return end

    isCarrying = true;

    TriggerEvent('ox_inventory:disarm', true)

    local disabledControls <const> = {};

    if itemData.walkOnly then
        local controls = { 21, 22, 24, 25 }
        for _, control in ipairs(controls) do
            table.insert(disabledControls, control)
        end
    end

    if itemData.blockVehicle then
        table.insert(disabledControls, 23)
    end

    lib.disableControls:Add(disabledControls)
    CreateThread(function()
        while isCarrying do
            lib.disableControls(); Wait(0);
        end

        lib.disableControls:Remove(disabledControls)
    end)

    LocalPlayer.state.canUseWeapons = false;
    exports.yseries:ToggleDisabled(true)

    while isCarrying do
        if itemData.blockVehicle then
            local vehicle = GetVehiclePedIsTryingToEnter(cache.ped)
            if DoesEntityExist(vehicle) or cache.vehicle then
                ClearPedTasksImmediately(cache.ped)
            end
        end

        if not IsEntityPlayingAnim(cache.ped, itemData.anim.dict, itemData.anim.clip, 3) and not LocalPlayer.state.isDead and not IsPedRagdoll(cache.ped) then
            lib.playAnim(cache.ped, itemData.anim.dict, itemData.anim.clip, 2.0, 2.0, -1, itemData.anim.flag, 0,
                false,
                false, false)
        end

        Wait(500);
    end

    exports.yseries:ToggleDisabled(false)
    LocalPlayer.state.canUseWeapons = true;
    SetPlayerSprint(cache.playerId, true)
end

AddEventHandler('ox_inventory:itemCount', function(itemName, totalCount)
    local itemData = CARRY_DATA[itemName];
    if not itemData then return false end
    LocalPlayer.state:set('carryItem', totalCount > 0 and itemName or nil, true);
end)
