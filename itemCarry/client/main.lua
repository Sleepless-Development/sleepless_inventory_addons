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

AddStateBagChangeHandler("carryItem", nil, function(bagName, key, carryData, _unused, replicated)
    local ply = GetPlayerFromStateBagName(bagName)
    local plyPed = GetPlayerPed(ply)

    if ply == 0 or plyPed ~= cache.ped then return end

    if carryData == nil then
        DeleteEntity(currentCarryObject)
        currentCarryObject = nil
        ClearPedTasks(cache.ped)
        return
    end

    if currentCarryObject then
        DeleteEntity(currentCarryObject)
        currentCarryObject = nil
    end


    lib.requestModel(carryData.prop.model)

    local plyPos = GetEntityCoords(cache.ped)
    lib.requestModel(carryData.prop.model, 1000)
    currentCarryObject = CreateObject(carryData.prop.model, plyPos.x, plyPos.y, plyPos.z + 0.2, true, true, true)
    SetEntityCollision(currentCarryObject, false, false)

    local placement = carryData.prop.placement

    AttachEntityToEntity(
        currentCarryObject,
        cache.ped,
        GetPedBoneIndex(cache.ped, carryData.prop.bone),
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

    lib.requestAnimDict(carryData.anim.dict, 1000)

    if carryData.walkOnly then
        local controls = {21, 22}
        lib.disableControls:Add(controls)
        CreateThread(function()
            while currentCarryObject do
                lib.disableControls()
                Wait(1)
            end
            lib.disableControls:Remove(controls)
        end)
    end

    while currentCarryObject do
        if carryData.blockVehicle then
            if DoesEntityExist(GetVehiclePedIsTryingToEnter(cache.ped)) then
                ClearPedTasks(cache.ped)
            end

            if IsPedInAnyVehicle(cache.ped, false) then
                ClearPedTasksImmediately(cache.ped)
            end

        end

        if not IsEntityPlayingAnim(cache.ped, carryData.anim.dict, carryData.anim.clip, 3) and not LocalPlayer.state.isdead and not LocalPlayer.state.isDead then
            TaskPlayAnim(cache.ped, carryData.anim.dict, carryData.anim.clip, 2.0, 2.0, -1, carryData.anim.flag, 0, false, false, false)
        end

        Wait(100)
    end

    SetPlayerSprint(cache.playerId, true)
end)


AddEventHandler('ox_inventory:updateInventory', function()
    TriggerServerEvent('carryItem:onUpdateInventory')
end)
