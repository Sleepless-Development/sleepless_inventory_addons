local config = {
    ['box'] = {
        disableMelee = true,
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
    ['tv'] = {
        walkOnly = false,
        disableMelee = true,
        blockVehicle = true,
        anim = {
            dict = 'anim@heists@box_carry@',
            clip = 'idle',
            flag = 51
        },
        prop = {
            bone = 60309,
            model = `prop_tv_06`,
            placement = {
                pos = vector3(0.115, 0.33000, 0.26),
                rot = vector3(-130.0, 114.0, 2.0),
            },
        },
    },
    ['big_tv'] = {
        walkOnly = false,
        disableMelee = true,
        blockVehicle = true,
        anim = {
            dict = 'anim@heists@box_carry@',
            clip = 'idle',
            flag = 51
        },
        prop = {
            bone = 60309,
            model = `prop_tv_flat_01`,
            placement = {
                pos = vector3(-0.015, 0.21, 0.325),
                rot = vector3(-126.0, 107.0, 6.0),
            },
        },
    },
    ['boombox'] = {
        disableMelee = true,
        blockVehicle = true,
        anim = {
            dict = 'anim@heists@box_carry@',
            clip = 'idle',
            flag = 51
        },
        prop = {
            bone = 60309,
            model = `prop_boombox_01`,
            placement = {
                pos = vector3(-0.04, 0.12, 0.28),
                rot = vector3(-142.0, 112.0, 6.0),
            },
        },
    },
    ['microwave'] = {
        disableMelee = true,
        blockVehicle = true,
        anim = {
            dict = 'anim@heists@box_carry@',
            clip = 'idle',
            flag = 51
        },
        prop = {
            bone = 60309,
            model = `prop_microwave_1`,
            placement = {
                pos = vector3(0.14, -0.005, 0.26),
                rot = vector3(-132.00, 111.0, 0.0),
            },
        },
    },
    ['golfclubs'] = {
        disableMelee = true,
        blockVehicle = true,
        anim = {
            dict = 'anim@heists@box_carry@',
            clip = 'idle',
            flag = 51
        },
        prop = {
            bone = 60309,
            model = `prop_golf_bag_01b`,
            placement = {
                pos = vector3(-0.135, 0.22, 0.36),
                rot = vector3(-68.0, -14.0, 35.0),
            },
        },
    },
    ['house_art'] = {
        disableMelee = true,
        blockVehicle = true,
        anim = {
            dict = 'anim@heists@box_carry@',
            clip = 'idle',
            flag = 51
        },
        prop = {
            bone = 60309,
            model = `h4_prop_h4_painting_01e`,
            placement = {
                pos = vector3(0.12, -0.025, 0.275),
                rot = vector3(44.0, -77.0, 168.0),
            },
        },
    },
    ['pc'] = {
        disableMelee = true,
        blockVehicle = true,
        anim = {
            dict = 'anim@heists@box_carry@',
            clip = 'idle',
            flag = 51
        },
        prop = {
            bone = 60309,
            model = `prop_dyn_pc_02`,
            placement = {
                pos = vector3(-0.04, 0.16, 0.26),
                rot = vector3(44.0, -77.0, 168.0),
            },
        },
    },
}

return config