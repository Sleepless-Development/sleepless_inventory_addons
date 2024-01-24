local Config = require 'backItems.config'
local PlayerState = LocalPlayer.state
local Utils = {}

local numDefaultSlotGroups = {}

for group, slots in pairs(Config.defaultSlots) do
    numDefaultSlotGroups[group] = #slots
end

local function getConfigData(slotData, config)
    local isWeapon = not config.model and slotData.name:find('WEAPON_') ~= nil -- if there is an alt model set, use object instead of weapon,  i.e. katana weapon, but have a sheathed model attached
    local hide = (CurrentWeapon and CurrentWeapon.slot == slotData.slot) or PlayerState.hideAllBackItems

    return {
        name = slotData.name,
        prio = config.prio or 1,
        group = config.group or 'back',
        hash = isWeapon and joaat(slotData.name) or nil,
        hide = hide,
        model = (type(config.model) == 'string' and joaat(config.model)) or config.model,
        isWeapon = isWeapon,
        components = isWeapon and slotData?.metadata?.components,
        tint = isWeapon and slotData?.metadata?.tint,
        customPos = config.customPos,
        ignoreLimits = config.ignoreLimits,
        flashlight = slotData?.metadata?.flashlight
    }
end

function Utils.formatCachedInventory(cache)
    local backItems = Config.BackItems
    local formattedInv = {}

    for _, slotData in pairs(cache) do
        local configData = backItems[slotData.name]
        if configData then
            formattedInv[#formattedInv + 1] = getConfigData(slotData, configData)
        end
    end

    table.sort(formattedInv, function(a, b)
        return a.prio > b.prio
    end)

    local takenGroupSlots = {}
    local finalItems = {}

    for i = 1, #formattedInv do
        local item = formattedInv[i]
        local group = item.group
        if group then
            takenGroupSlots[group] = takenGroupSlots[group] or 0
        end
        if takenGroupSlots[group] < numDefaultSlotGroups[group] or item.ignoreLimits then
            if not item.ignoreLimits then
                takenGroupSlots[group] = takenGroupSlots[group] + 1
                local defaultData = Config.defaultSlots[group][takenGroupSlots[group]]

                item.pos = Utils.getOverride(defaultData.pos, item?.customPos?.pos)
                item.rot = Utils.getOverride(defaultData.rot, item?.customPos?.rot)
                item.bone = item?.customPos?.bone or defaultData.bone
            else
                if not Utils.isCustomPosValid(item.customPos) then
                    print('^1 ERROR: item with ignoreLimits needs a custom Position^7', item.name)
                    return
                end
                item.pos = item.customPos.pos
                item.rot = item.customPos.rot
                item.bone = item.customPos.bone
            end
            finalItems[#finalItems + 1] = item
        end
    end

    return finalItems
end

-- Weapon functions

function Utils.hasFlashLight(components)
    if components and next(components) then
        for i = 1, #components do
            local component = components[i]

            if component:find('flashlight') then
                return true
            end
        end
    end

    return false
end

function Utils.checkFlashState(weapon)
    local flashState = LocalPlayer.state.flashState

    if flashState and flashState[weapon.serial] and Utils.hasFlashLight(weapon.components) then
        return true
    end

    return false
end

-- Object Functions

function Utils.getOverride(vec, override)
    if not override then return vec3(vec.x, vec.y, vec.z) end

    vec = {table.unpack(vec)}

    vec.x = override.x or (vec.x or vec[1])
    vec.y = override.y or (vec.y or vec[2])
    vec.z = override.z or (vec.z or vec[3])

    return vec3(vec.x, vec.y, vec.z)
end

function Utils.isCustomPosValid(data)
    if not data then return end

    if not data.bone then return end
    if not data.pos then return end
    if not data.rot then return end
    if not data.pos.x or not data.pos.y or not data.pos.z then return end
    if not data.rot.x or not data.rot.y or not data.rot.z then return end


    return true
end

return Utils
