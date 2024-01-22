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
        { bone = 24818, pos = vec3(0.09, -0.16, 0.00),  rot = vec3(0.0, 180.0, 0.0) },
        { bone = 24818, pos = vec3(0.09, -0.16, -0.12), rot = vec3(0.0, 180.0, 0.0) }
    },
    -- ['another group'] = { -- add as many slot groups as you like for different types of items
    --     { bone = 24818, pos = vec3(0.09, -0.16, 0.12),  rot = vec3(0.0, 180.0, 0.0) },
    --     { bone = 24818, pos = vec3(0.09, -0.16, 0.00),  rot = vec3(0.0, 180.0, 0.0) },
    --     { bone = 24818, pos = vec3(0.09, -0.16, -0.12), rot = vec3(0.0, 180.0, 0.0) }
    -- },
}

--- Back items configuration
---@type table<string, BackItem>
Config.BackItems = {
    ['WEAPON_CARBINERIFLE'] = {
        prio = 3,
        group = 'back'
    },
    ['WEAPON_SNIPERRIFLE'] = {
        prio = 3,
        group = 'back'
    },
    ['WEAPON_COMPACTRIFLE'] = {
        prio = 2,
        group = 'back'
    },
    ['WEAPON_MG'] = {
        prio = 4,
        group = 'back'
    },
    ['WEAPON_BAT'] = {
        prio = 1,
        group = 'back',
        customPos = {
            pos = { x = 0.4, y = -0.15 },
            rot = { y = 270.0 }
        }
    },
    ['cone'] = {
        prio = 1,
        ignoreLimits = true,
        model = `prop_roadcone02a`,
        customPos = {
            bone = 12844,
            pos = vec3(0.06, 0.0, 0.0),
            rot = vec3(0.0, 90.0, 0.0)
        }
    }
}

return Config
