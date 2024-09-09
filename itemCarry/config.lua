local config = {
    ['oxy_package'] = {
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

    ['wheel'] = {
        walkOnly = true,
        blockVehicle = true,
        anim = {
            dict = 'anim@heists@box_carry@',
            clip = 'idle',
            flag = 51
        },
        prop = {
            bone = 60309,
            model = `prop_wheel_01`,
            placement = {
                pos = vector3(0.025000, 0.080000, 0.255000),
                rot = vector3(-145.000000, 290.000000, 0.000000),
            },
        },
    },

    ['house_tv'] = {
        walkOnly = true,
        blockVehicle = true,
        anim = {
            dict = 'anim@heists@box_carry@',
            clip = 'idle',
            flag = 51
        },
        prop = {
            bone = 60309,
            model = `prop_tv_flat_03`,
            placement = {
                pos = vector3(0.025000, 0.080000, 0.255000),
                rot = vector3(-120.000000, 100.000000, 10.000000),
            },
        },
    },

    ['house_toaster'] = {
        walkOnly = true,
        blockVehicle = true,
        anim = {
            dict = 'anim@heists@box_carry@',
            clip = 'idle',
            flag = 51
        },
        prop = {
            bone = 60309,
            model = `prop_toaster_01`,
            placement = {
                pos = vector3(0.025000, 0.080000, 0.255000),
                rot = vector3(-50.000000, 290.000000, 0.000000),
            },
        },
    },

    ['house_washer'] = {
        walkOnly = true,
        blockVehicle = true,
        anim = {
            dict = 'anim@heists@box_carry@',
            clip = 'idle',
            flag = 51
        },
        prop = {
            bone = 60309,
            model = `prop_washer_01`,
            placement = {
                pos = vector3(0.1000, 0.010000, 0.25000),
                rot = vector3(-110.000000, 100.000000, 5.000000),
            },
        },
    },

    ['house_lamp'] = {
        walkOnly = true,
        blockVehicle = true,
        anim = {
            dict = 'anim@heists@box_carry@',
            clip = 'idle',
            flag = 51
        },
        prop = {
            bone = 60309,
            model = `v_res_m_lamptbl_off`,
            placement = {
                pos = vector3(0.025000, 0.080000, 0.255000),
                rot = vector3(-120.000000, 100.000000, 10.000000),
            },
        },
    },

    ['house_box'] = {
        walkOnly = true,
        blockVehicle = true,
        anim = {
            dict = 'anim@heists@box_carry@',
            clip = 'idle',
            flag = 51
        },
        prop = {
            bone = 60309,
            model = `m23_1_prop_m31_roostercrate_02a`,
            placement = {
                pos = vector3(0.025000, 0.080000, 0.255000),
                rot = vector3(-100.000000, 100.000000, 10.000000),
            },
        },
    },
}

return config
