AddEventHandler("playerDropped", function()
    Player(source).state:set('backItems', false, true)
end)

AddEventHandler('playerJoining', function(source)
    Player(source).state:set('backItems', false, true)
end)


AddStateBagChangeHandler('flashlightState', '', function(bagName, _, state)
    local source = GetPlayerFromStateBagName(bagName)
    local currentWeapon = exports.ox_inventory:GetCurrentWeapon(source)

    currentWeapon.metadata.flashlight = state
    exports.ox_inventory:SetMetadata(source, currentWeapon.slot, currentWeapon.metadata)
end)