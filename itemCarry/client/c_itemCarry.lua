local currentCarryObject = nil

local function onLoad()
    LocalPlayer.state:set('carryItem', nil, true)
    TriggerServerEvent("carryItem:onUpdateInventory")
end

RegisterNetEvent('esx:playerLoaded', onLoad)
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', onLoad)
RegisterNetEvent('ox:playerLoaded', onLoad)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        if currentCarryObject then
            DeleteEntity(currentCarryObject)
            ClearPedTasks(cache.ped)
        end
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        LocalPlayer.state:set('carryItem', nil, true)
        TriggerServerEvent("carryItem:onUpdateInventory")
    end
end)

AddStateBagChangeHandler("carryItem", nil, function(bagName, key, propData, _unused, replicated)
    local ply = GetPlayerFromStateBagName(bagName)
    local plyPed = GetPlayerPed(ply)

    if ply == 0 or plyPed ~= cache.ped then return end

    if propData == nil then
        DeleteEntity(currentCarryObject)
        currentCarryObject = nil
        ClearPedTasks(cache.ped)
        return
    end

    if currentCarryObject then
        DeleteEntity(currentCarryObject)
        currentCarryObject = nil
    end


    lib.requestModel(propData.prop.model)

    local plyPos = GetEntityCoords(cache.ped)
    lib.requestModel(propData.prop.model, 1000)
    currentCarryObject = CreateObject(propData.prop.model, plyPos.x, plyPos.y, plyPos.z + 0.2, true, true, true)
    SetEntityCollision(currentCarryObject, false, false)

    local placement = propData.prop.placement

    AttachEntityToEntity(
        currentCarryObject,
        cache.ped,
        GetPedBoneIndex(cache.ped, propData.prop.bone),
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

    lib.requestAnimDict(propData.dictionary, 1000)

    if propData.walkOnly then
        SetPlayerSprint(cache.playerId, false)
    end

    while currentCarryObject do
        if propData.blockVehicle and DoesEntityExist(GetVehiclePedIsTryingToEnter(cache.ped)) then
            ClearPedTasks(cache.ped)
        end

        if not IsEntityPlayingAnim(cache.ped, propData.dictionary, propData.animation, 3) and not LocalPlayer.state.isdead and not LocalPlayer.state.isDead then ---@todo may need to add dead checks and other things here as well
            TaskPlayAnim(cache.ped, propData.dictionary, propData.animation, 2.0, 2.0, -1, propData.flag, 0, false, false, false)
        end

        Wait(100)
    end

    SetPlayerSprint(cache.playerId, true)
end)


AddEventHandler('ox_inventory:updateInventory', function()
    TriggerServerEvent('carryItem:onUpdateInventory')
end)
