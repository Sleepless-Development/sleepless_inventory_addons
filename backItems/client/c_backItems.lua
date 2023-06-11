-- Local variable declaration
local ox_inventory = exports.ox_inventory
local playerBackSlots = {}
local inventoryItems = exports.ox_inventory:Items()

-- Function to delete weapon entities and reset backData
local function deleteBackItems(serverId)
    for i = 1, #playerBackSlots[serverId] do
        DeleteEntity(playerBackSlots[serverId][i].obj)
        playerBackSlots[serverId][i].obj = nil
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


local function onLoad()
    LocalPlayer.state:set('backItems', BACK_ITEM_SLOTS_DEFAULT, true)
    TriggerServerEvent("backItems:loadForSpawn")
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
        LocalPlayer.state:set('backItems', BACK_ITEM_SLOTS_DEFAULT, true)
        Wait(500)
        TriggerServerEvent("backItems:loadForSpawn")
    end
end)

-- Function to handle weapon creation
local function createWeapon(serverId, i)
    local slotData = playerBackSlots[serverId][i]
    lib.requestWeaponAsset(slotData.backData.hash, 2000, 31, 0)
    local coords = GetEntityCoords(cache.ped)
    playerBackSlots[serverId][i].obj = CreateWeaponObject(slotData.backData.hash, 0, coords.x, coords.y, coords.z, false, 1.0, false)

    SetEntityCollision(playerBackSlots[serverId][i].obj, false, false)
    RequestWeaponHighDetailModel(playerBackSlots[serverId][i].obj)
end

local function createObject(serverId, i)
    local slotData = playerBackSlots[serverId][i]
    local model = slotData.backData.model

    lib.requestModel(model, 2000)
    playerBackSlots[serverId][i].obj = CreateObject(model, 1.0, 1.0, 1.0, false, false, false)

    SetEntityCollision(playerBackSlots[serverId][i].obj, false, false)
end

-- Function to handle weapon components
local function handleWeaponComponents(serverId, i)
    local slotData = playerBackSlots[serverId][i]
    local tryComponent = ("COMPONENT_%s_CLIP_01"):format(string.gsub(slotData.backData.name, "WEAPON_", "")) --[[@as number]]
    tryComponent = joaat(tryComponent)
    local componentModel = GetWeaponComponentTypeModel(tryComponent)
    if componentModel ~= 0 then
        lib.requestModel(componentModel, 2000)
        GiveWeaponComponentToWeaponObject(playerBackSlots[serverId][i].obj, tryComponent)
    end

    for k = 1, #slotData.backData.attachments do
        local components = inventoryItems[slotData.backData.attachments[k]].client.component
        for v= 1, #components do
            local component = components[v]
            if DoesWeaponTakeWeaponComponent(slotData.backData.hash, component) then
                if not HasWeaponGotWeaponComponent(playerBackSlots[serverId][i].obj, component) then
                    local componentModel = GetWeaponComponentTypeModel(component)
                    lib.requestModel(componentModel, 2000)
                    GiveWeaponComponentToWeaponObject(playerBackSlots[serverId][i].obj, component)
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
        Wait(0)
        for serverId, backItems in pairs(playerBackSlots) do
            for i = 1, #backItems do
                local backItem = backItems[i]?.obj
                if backItem then
                    local targetPed = GetPlayerPed(GetPlayerFromServerId(serverId))
                    if targetPed then
                        if not IsEntityAttachedToEntity(backItem, targetPed) then
                            attachItemToPlayer(serverId, i, targetPed)
                        end
                    end
                end
            end
        end
    end
end)

AddStateBagChangeHandler("backItemEquipped", nil, function(bagName, key, data, _unused, replicated)
    local ply = GetPlayerFromStateBagName(bagName)
    local serverId = GetPlayerServerId(ply)

    SetEntityVisible(playerBackSlots[serverId][data.slot].obj, data.toggle, false)
end)

-- Handler for state bag change
AddStateBagChangeHandler("backItems", nil, function(bagName, key, newSlotsData, _unused, replicated)

    local ply = GetPlayerFromStateBagName(bagName)

    if not ply then return end

    local plyPed = GetPlayerPed(ply)
    local serverId = GetPlayerServerId(ply)

    while plyPed == 0 or not HasCollisionLoadedAroundEntity(plyPed) do
        Wait(0)
        plyPed = GetPlayerPed(ply)
        if not DoesEntityExist(plyPed) then return end
    end

    if not playerBackSlots[serverId] then
        playerBackSlots[serverId] = lib.table.deepclone(BACK_ITEM_SLOTS_DEFAULT)
    end

    deleteBackItems(serverId)



    for i = 1, #newSlotsData do

        if not playerBackSlots[serverId][i] then
            playerBackSlots[serverId][i] = {backData = false}
        end

        playerBackSlots[serverId][i].backData = newSlotsData[i]

        local slotData = playerBackSlots[serverId][i]
        if slotData.backData then
            if slotData.obj then
                DeleteEntity(playerBackSlots[serverId][i].obj)
                playerBackSlots[serverId][i].obj = nil
            end
            if slotData.backData.isWeapon then
                createWeapon(serverId, i)
                handleWeaponComponents(serverId, i)
            elseif slotData.backData.model then
                createObject(serverId, i)
            end
            SetEntityDrawOutline(playerBackSlots[serverId][i].obj, true)
            attachItemToPlayer(serverId, i, plyPed)
        else
            if playerBackSlots[serverId][i].obj then
                DeleteEntity(playerBackSlots[serverId][i].obj)
                playerBackSlots[serverId][i].obj = nil
                playerBackSlots[serverId][i].backData = false
            end
        end
    end
end)

 local lastSlot = nil
 local function findItemAndSetVisible(visible)
     local serverId = cache.serverId

     if not playerBackSlots[serverId] then return end

     for i = 1, #playerBackSlots[serverId] do
         local backSlot = playerBackSlots[serverId][i]
         local plyState = LocalPlayer.state
         if backSlot?.backData?.slot == lastSlot then
             SetEntityVisible(backSlot.obj, visible, false)
             plyState:set("backItemEquipped", {toggle = visible, slot = i}, true)
             return
         end
     end
 end

 local function setAllBackItemsVisible(visible)
    local serverId = cache.serverId

    if not playerBackSlots[serverId] then return end

    for i = 1, #playerBackSlots[serverId] do
        local backSlot = playerBackSlots[serverId][i]
        local plyState = LocalPlayer.state
        if backSlot?.backData?.slot == lastSlot then
            SetEntityVisible(backSlot.obj, visible, false)
            plyState:set("backItemEquipped", {toggle = visible, slot = i}, true)
        end
    end
end

lib.onCache("weapon", function (weapon)
    if weapon then
        lastSlot = ox_inventory:getCurrentWeapon().slot
        findItemAndSetVisible(false)
    else
        findItemAndSetVisible(true)
    end
end)

lib.onCache("vehicle", function (vehicle)
    if vehicle then
        setAllBackItemsVisible(false)
    else
        setAllBackItemsVisible(true)
    end
end)

exports("setAllBackItemsVisible", setAllBackItemsVisible)
