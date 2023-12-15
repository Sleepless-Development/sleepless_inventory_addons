-- Local variable declaration
local playerBackSlots = {}

-- Function to delete weapon entities and reset backData
local function deleteBackItems(serverId)
    for i = 1, #playerBackSlots[serverId] do
        if playerBackSlots[serverId][i].obj then
            DeleteEntity(playerBackSlots[serverId][i].obj)
            playerBackSlots[serverId][i].obj = nil
        end
        playerBackSlots[serverId][i] = BACK_ITEM_SLOTS_DEFAULT[i] and lib.table.deepclone(BACK_ITEM_SLOTS_DEFAULT[i]) or nil
    end
end

local function purgeAllBackItems()
    for serverId, weapons in pairs(playerBackSlots) do
        if weapons then
            deleteBackItems(serverId)
        end
    end
end

-- Function to handle backItems on player load
local function onLoad()
    LocalPlayer.state:set('backItems', BACK_ITEM_SLOTS_DEFAULT, true)
    Wait(1000)
    TriggerServerEvent("backItems:onUpdateInventory")
end

RegisterNetEvent('esx:playerLoaded', onLoad)
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', onLoad)
RegisterNetEvent('ox:playerLoaded', onLoad)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        purgeAllBackItems()
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        onLoad()
    end
end)

-- Function to handle weapon creation
local function createWeapon(serverId, i)
    local slotData = playerBackSlots[serverId][i]

    lib.requestWeaponAsset(slotData.backData.hash, 2000, 31, 0)
    local coords = GetEntityCoords(cache.ped)
    playerBackSlots[serverId][i].obj = CreateWeaponObject(slotData.backData.hash, 0, coords.x, coords.y, coords.z, true, 1.0, false)

    SetEntityCollision(playerBackSlots[serverId][i].obj, false, false)
end

local function createObject(serverId, i)
    local slotData = playerBackSlots[serverId][i]
    local model = slotData.backData.hash

    lib.requestModel(model, 2000)
    playerBackSlots[serverId][i].obj = CreateObject(model, 1.0, 1.0, 1.0, false, false, false)

    SetEntityCollision(playerBackSlots[serverId][i].obj, false, false)
end

-- Function to handle weapon components
local function handleWeaponComponents(serverId, i)
    local slotData = playerBackSlots[serverId][i]
    local tryComponent = ("COMPONENT_%s_CLIP_01"):format(string.gsub(slotData.backData.name, "WEAPON_", "")) --[[@as number]]
    local weapon = playerBackSlots[serverId][i].obj
    tryComponent = joaat(tryComponent)
    local componentModel = GetWeaponComponentTypeModel(tryComponent)
    if componentModel ~= 0 and DoesEntityExist(playerBackSlots[serverId][i].obj) and not HasWeaponGotWeaponComponent(weapon, tryComponent) then
        lib.requestModel(componentModel, 2000)
        GiveWeaponComponentToWeaponObject(playerBackSlots[serverId][i].obj, tryComponent)
    end

    if slotData.backData.tint then
        SetWeaponObjectTintIndex(playerBackSlots[serverId][i].obj, slotData.backData.tint)
    end

    if slotData.backData.attachments then
        for k = 1, #slotData.backData.attachments do
            local components = INVENTORY_ITEMS[slotData.backData.attachments[k]].client.component
            for v = 1, #components do
                local component = components[v]
                if DoesWeaponTakeWeaponComponent(slotData.backData.hash, component) then
                    if not HasWeaponGotWeaponComponent(playerBackSlots[serverId][i].obj, component) and DoesEntityExist(playerBackSlots[serverId][i].obj) then
                        local componentModel = GetWeaponComponentTypeModel(component)
                        lib.requestModel(componentModel, 2000)
                        GiveWeaponComponentToWeaponObject(playerBackSlots[serverId][i].obj, component)
                    end
                end
            end
        end
    end
end

-- A function to handle attaching items to player
local function attachItemToPlayer(serverId, i, plyPed)
    local slotData = playerBackSlots[serverId][i]
    local object = slotData.obj
    local rot = slotData.backData?.customPos?.rot
    local pos = slotData.backData?.customPos?.pos
    local overrideDefaultZ = slotData.backData?.customPos?.overrideDefaultZ
    local bone = slotData.backData?.customPos?.bone

    AttachEntityToEntity(
        object,
        plyPed,
        GetPedBoneIndex(plyPed, bone or 24818),
        pos?.x or 0.09,
        pos?.y or -0.16,
        (overrideDefaultZ and pos?.z) or slotData.defaultoffset,
        rot?.x or 0.0,
        rot?.y or 180.0,
        rot?.z or 0.0,
        true, false, false, true, 2, true)
end

-- Thread to handle periodic operations
CreateThread(function()
    while true do
        Wait(1000)
        for serverId, backItems in pairs(playerBackSlots) do
            for i = 1, #backItems do
                local backItem = backItems[i]?.obj
                if backItem then
                    local player = GetPlayerFromServerId(serverId)
                    local targetPed = GetPlayerPed(player)
                    if targetPed and DoesEntityExist(targetPed) and type(player) == "number" and player > 0 then
                        if DoesEntityExist(backItem) and not IsEntityAttachedToEntity(backItem, targetPed) then
                            attachItemToPlayer(serverId, i, targetPed)
                        end
                    else
                        deleteBackItems(serverId)
                    end
                end
            end
        end
    end
end)

-- Handler for state bag change
AddStateBagChangeHandler("backItems", nil, function(bagName, key, newSlotsData, _unused, replicated)
    local ply = GetPlayerFromStateBagName(bagName)

    if type(ply) ~= "number" or ply < 1 then return end

    local plyPed = GetPlayerPed(ply)
    local serverId = GetPlayerServerId(ply)

    while plyPed == 0 or not HasCollisionLoadedAroundEntity(plyPed) do
        Wait(0)
        plyPed = GetPlayerPed(ply)
        if not DoesEntityExist(plyPed) then
            print('plyPed did not exist, returning', plyPed)
            return
        end
    end

    if not playerBackSlots[serverId] then
        playerBackSlots[serverId] = lib.table.deepclone(BACK_ITEM_SLOTS_DEFAULT)
    end

    deleteBackItems(serverId)

    for i = 1, #newSlotsData do
        if not playerBackSlots[serverId][i] then
            playerBackSlots[serverId][i] = { backData = false }
        end

        playerBackSlots[serverId][i].backData = newSlotsData[i]

        local slotData = playerBackSlots[serverId][i]

        if slotData.backData then
            if slotData.backData.visible then
                if slotData.obj then
                    DeleteEntity(playerBackSlots[serverId][i].obj)
                    playerBackSlots[serverId][i].obj = nil
                end

                if not slotData.backData.hash then
                    if slotData.backData.name then
                        print(("[ERROR]: no hash value in data for %s"):format(slotData.backData.name))
                    end
                    return
                end

                if IsWeaponValid(slotData.backData.hash) then
                    createWeapon(serverId, i)
                    handleWeaponComponents(serverId, i)
                else
                    createObject(serverId, i)
                end
                attachItemToPlayer(serverId, i, plyPed)
            end
        else
            if playerBackSlots[serverId][i].obj then
                DeleteEntity(playerBackSlots[serverId][i].obj)
                playerBackSlots[serverId][i].obj = nil
                playerBackSlots[serverId][i].backData = false
            end
        end
    end
end)

local function hideAllBackItems(hide)
    LocalPlayer.state:set("hideAllBackItems", hide, true)
end

exports("hideAllBackItems", hideAllBackItems)

lib.onCache("weapon", function(weapon)
    TriggerServerEvent('backItems:onUpdateInventory', weapon)
end)

lib.onCache("vehicle", function(vehicle)
    if vehicle then
        if IsThisModelABike(GetEntityModel(vehicle)) then return end
        hideAllBackItems(true)
    else
        hideAllBackItems(false)
    end
end)

RegisterNetEvent("backItems:RemoveItemsOnDropped", function(serverId)
    if not playerBackSlots[serverId] then return end

    for i = 1, #playerBackSlots[serverId] do
        local backSlot = playerBackSlots[serverId][i]
        if DoesEntityExist(backSlot.obj) then
            DeleteEntity(backSlot.obj)
        end
    end
    playerBackSlots[serverId] = nil
end)

local function shouldUpdate(changes)
    local weapon = exports.ox_inventory:getCurrentWeapon()
    for _, change in pairs(changes) do
        if change == false or (type(change) == 'table' and change.slot ~= weapon?.slot and BACK_ITEMS[change.name]) then
            return true
        end
    end
    return false
end

AddEventHandler('ox_inventory:updateInventory', function(changes)
    if not shouldUpdate(changes) then return end
    TriggerServerEvent('backItems:onUpdateInventory', cache.weapon)
end) 