AddEventHandler("playerDropped", function()
    Player(source).state:set('backItems', false, true)
    TriggerClientEvent('backItems:clearPlayerItems', -1, source)
end)

AddEventHandler('playerJoining', function(source)
    Player(source).state:set('backItems', false, true)
end)

--[[ CreateThread(function()
    local defaultBucket = 0;

    while true do
        local allPlayers = GetPlayers();
        for _, playerId in pairs(allPlayers) do
            local plyState = Player(playerId).state
            local playerBucket = GetPlayerRoutingBucket(playerId);

            if plyState['bucket'] == nil then
                lib.print.debug('Player ' .. playerId .. ' has no bucket, setting to ' .. playerBucket);
                plyState:set('bucket', playerBucket, true);
            end

            if plyState['bucket'] ~= playerBucket then
                lib.print.debug('Player ' ..
                    playerId .. ' changed bucket from ' .. plyState['bucket'] .. ' to ' .. playerBucket);
                plyState:set('bucket', playerBucket, true);
            end
        end

        Wait(5000);
    end
end) ]]


AddStateBagChangeHandler('flashlightState', '', function(bagName, _, state)
    local source = GetPlayerFromStateBagName(bagName)
    local currentWeapon = exports.ox_inventory:GetCurrentWeapon(source)

    currentWeapon.metadata.flashlight = state
    exports.ox_inventory:SetMetadata(source, currentWeapon.slot, currentWeapon.metadata)
end)
