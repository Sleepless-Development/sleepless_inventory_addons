local config = {
    ['box'] = {
        walkOnly = true,
        blockVehicle = true,
        anim = {
            dict = 'anim@heists@box_carry@',
            clip = 'idle',
            flag = 51
        },
        prop = {
            bone = 60309,
            model = `hei_prop_heist_box`,
            placement = {
                pos = vector3(0.025000, 0.080000, 0.255000),
                rot = vector3(-145.000000, 290.000000, 0.000000),
            },
        },
    },
}

return config