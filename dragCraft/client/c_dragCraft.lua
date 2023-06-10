RegisterNetEvent('demi-dragCraft:Craft', function(duration)
    TriggerServerEvent('ox_inventory:closeInventory')
    local result = lib.progressCircle({
        duration = duration,
        label = 'Crafting...',
        position = 'middle',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
        },
        anim = {
            dict = 'amb@prop_human_parking_meter@male@base',
            clip = 'base'
        },
    })

    lib.callback('demi-dragCraft:success', false, function()
    end, result)
end)
