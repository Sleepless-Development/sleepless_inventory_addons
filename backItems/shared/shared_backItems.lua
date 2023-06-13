BACK_ITEM_LIMIT = 3 --if you increase this, you must also add a new entry in BACK_ITEM_SLOTS_DEFAULT below with a defaultoffset

BACK_ITEM_SLOTS_DEFAULT = {
    [1] = { backData = false, defaultoffset = 0.12 },
    [2] = { backData = false, defaultoffset = 0.00 },
    [3] = { backData = false, defaultoffset = -0.12 }
}

BACK_ITEMS  = {
    ['WEAPON_CARBINERIFLE'] = {
        prio = 3,
        isWeapon = true,
        hash = joaat('WEAPON_CARBINERIFLE')
    },
    ['WEAPON_COMPACTRIFLE'] = {
        prio = 2,
        isWeapon = true,
        hash = joaat('WEAPON_COMPACTRIFLE'),
    },
    ['WEAPON_MG'] = {
        prio = 4,
        isWeapon = true,
        hash = joaat('WEAPON_MG'),
    },
    ['WEAPON_BAT'] = {
        prio = 1,
        isWeapon = true,
        hash = joaat('WEAPON_BAT'),
        customPos = {
            pos = vec3(0.4, -0.15, 0.0),
            rot = vec3(0.0, 270.0, 0.0)
        }
    },
    ['cone'] = {
        prio = 1,
        ignoreLimits = true,
        model = joaat('prop_roadcone02a'),
        customPos = {
            bone = 12844,
            overrideDefaultZ = true,
            pos = vec3(0.06, 0.0, 0.0),
            rot = vec3(0.0, 90.0, 0.0)
        }
    }
}