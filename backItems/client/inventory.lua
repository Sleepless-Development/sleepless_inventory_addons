local Utils = require 'backItems.imports.utils'
local Config = require 'backItems.config'
local PlayerState = LocalPlayer.state

InvCache = {}
CurrentWeapon = nil

function UpdateBackItems()
    local formattedData = Utils.formatCachedInventory(InvCache)

    if not lib.table.matches(formattedData, PlayerState.backItems) then
        PlayerState:set('backItems', formattedData, true)
    end
end

local function shouldUpdate(slot, change)
    local backitems = Config.BackItems
    local last = InvCache[slot]
    local update = (last and backitems[last.name]) or change and backitems[change.name]

    return update
end

AddEventHandler('ox_inventory:updateInventory', function(changes)
    if not changes then return end

    local needsUpdate = false


    for slot, change in pairs(changes) do
        if not needsUpdate then
            needsUpdate = shouldUpdate(slot, change)
        end

        InvCache[slot] = change or nil
    end

    if needsUpdate then
        UpdateBackItems()
    end
end)

local function flashlightLoop()
    if not CurrentWeapon then return end

    local state = CurrentWeapon.metadata.flashlight

    if state then
        SetFlashLightEnabled(cache.ped, true)
    end

    while CurrentWeapon do
        local currentState = IsFlashLightOn(cache.ped)
        if state ~= currentState then
            state = currentState
            PlayerState:set('flashlightState', state, true)
        end
        Wait(100)
    end
end

AddEventHandler('ox_inventory:currentWeapon', function(weapon)
    CurrentWeapon = weapon
    UpdateBackItems()

    if weapon and Utils.hasFlashLight(weapon.metadata.components) then
        flashlightLoop()
    end
end)

lib.onCache('ped', RefreshBackItems)

lib.onCache('vehicle', function(vehicle)
    local toggle = vehicle ~= false
    PlayerState:set('hideAllBackItems', toggle, true)
    UpdateBackItems()
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Wait(100)
        InvCache = exports.ox_inventory:GetPlayerItems()
        CurrentWeapon = exports.ox_inventory:getCurrentWeapon()
        RefreshBackItems()
    end
end)
