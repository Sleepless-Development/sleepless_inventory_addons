--- Defines a slot with a bone, position, and rotation
---@class Slot
---@field bone number
---@field pos vector3
---@field rot vector3

---@class OptionalVector
---@field x? number
---@field y? number
---@field z? number

--- Defines an item with properties for its placement and grouping
---@class BackItem
---@field prio number a number to define the priority of importance that the weapon should appear over others
---@field group? string which slot group the item should use. defaults to 'back'
---@field customPos? {bone?: number , pos?: OptionalVector | vector3,  rot?:  OptionalVector | vector3} optional custom position. required if ignorelimits is true
---@field ignoreLimits? boolean wether or not the item is attached regardless of available slots. requires a full custom position. a full custom position has a bone, pos as a vec3, and rot as a vec3
---@field model? number | string this is required for non-weapon items. can optionally be used for weapons in order to have the attached model different than the equipped model. like if you want a sheathed katanta on your back

---@class Config
---@field defaultSlots table<string, Slot[]>
---@field BackItems table<string, BackItem>

--- Configurations for item slots and back items
local Config = {}

--- Default slots configuration
---@type table<string, Slot[]>
Config.defaultSlots = {
    ['back'] = {
        { bone = 24818, pos = vec3(0.09, -0.16, 0.12),  rot = vec3(0.0, 180.0, 0.0) },
        --{ bone = 24818, pos = vec3(0.09, -0.16, 0.00),  rot = vec3(0.0, 180.0, 0.0) },
        { bone = 24818, pos = vec3(0.09, -0.16, -0.12), rot = vec3(0.0, 180.0, 0.0) }
    },

    ['side'] = {
        { bone = 24817, pos = vec3(-0.3, 0.05, -0.23), rot = vec3(100.0, 160.0, 0.0) },
        { bone = 24817, pos = vec3(-0.3, 0.05, 0.215), rot = vec3(100.0, 160.0, 0.0) },
    },
}

--- these vehicle classes will be allowed to display all attached back items
Config.allowedVehicleClasses = {
    [8] = true,  -- motorcycles
    [13] = true, -- bicycles
    [14] = true, -- boats
}

--- Back items configuration
---@type table<string, BackItem>

Config.BackItems = {
    ['WEAPON_PETROLCAN'] = {
        prio      = 6,
        group     = 'back',
        customPos = {
            pos = { x = 0.0, y = -0.15, z = 0.06 },
            rot = { y = -270.0 }
        },
    },

    ['WEAPON_FERTILIZERCAN'] = {
        prio = 6,
        group = 'back',
        customPos = {
            pos = { x = 0.0, y = -0.15, z = 0.06 },
            rot = { y = -270.0 }
        }
    },

    ['WEAPON_MINISMG'] = {
        prio = 4,
        group = 'back'
    },

    ['WEAPON_MICROSMG'] = {
        prio = 4,
        group = 'back'
    },

    ['WEAPON_SMG'] = {
        prio = 4,
        group = 'back'
    },

    ['WEAPON_MUSKET'] = {
        prio = 4,
        group = 'back'
    },

    ['WEAPON_BEANBAG'] = {
        prio = 4,
        group = 'back'
    },

    ['WEAPON_ASSAULTRIFLE'] = {
        prio = 5,
        group = 'back'
    },

    ['WEAPON_PUMPSHOTGUN'] = {
        prio = 5,
        group = 'back'
    },

    ['WEAPON_CARBINERIFLE'] = {
        prio = 5,
        group = 'back'
    },

    ['WEAPON_SNIPERRIFLE'] = {
        prio = 5,
        group = 'back'
    },

    ['WEAPON_COMBATSHOTGUN'] = {
        prio = 5,
        group = 'back'
    },

    ['WEAPON_PISTOL'] = {
        prio = 1,
        group = 'side',
    },

    ['WEAPON_STUNGUN_MP'] = {
        prio = 2,
        group = 'side',
    },

    ['WEAPON_COMBATPISTOL'] = {
        prio = 2,
        group = 'side',
    },

    ['WEAPON_APPISTOL'] = {
        prio = 3,
        group = 'side',
    },

    ['WEAPON_POOLCUE'] = {
        prio = 2,
        group = 'back',
        customPos = {
            pos = { x = 0.4, y = -0.15 },
            rot = { y = 270.0 }
        }
    },

    ['WEAPON_GOLFCLUB'] = {
        prio = 2,
        group = 'back',
        customPos = {
            pos = { x = 0.4, y = -0.15 },
            rot = { y = 270.0 }
        }
    },

    ['WEAPON_WRENCH'] = {
        prio = 1,
        group = 'back',
        customPos = {
            pos = { x = -0.15, y = -0.15 },
            rot = { y = -270.0 }
        }
    },

    ['WEAPON_MACHETE'] = {
        prio = 1,
        group = 'back',
        customPos = {
            pos = { x = -0.15, y = -0.15 },
            rot = { y = -270.0 }
        }
    },

    ['WEAPON_CROWBAR'] = {
        prio = 1,
        group = 'back',
        customPos = {
            pos = { x = -0.1, y = -0.15 },
            rot = { y = -270.0 }
        }
    },

    ['WEAPON_BAT'] = {
        prio = 2,
        group = 'back',
        customPos = {
            pos = { x = 0.4, y = -0.15 },
            rot = { y = 270.0 }
        }
    },

    ['backpack'] = {
        prio = 6,
        ignoreLimits = true,
        model = `p_michael_backpack_s`,
        customPos = {
            bone = 24818,
            pos = vec3(0.07, -0.11, -0.05),
            rot = vec3(0.0, -90.0, 175.0)
        }
    },

    ['big_backpack'] = {
        prio = 7,
        ignoreLimits = true,
        model = `p_ld_heist_bag_s`,
        customPos = {
            bone = 24818,
            pos = vec3(-0.06, -0.07, -0.0),
            rot = vec3(0.0, -90.0, 175.0)
        }
    }
}

return Config
