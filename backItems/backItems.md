# `backItems` 2.0

## Overview

you can find the config in `backitems/config.lua`

The `backItems` module comprises two main configurations:

1. **Default Slots Configuration (`defaultSlots`)**
2. **Back Items Configuration (`BackItems`)**

### 1. Default Slots Configuration (`defaultSlots`)

This configuration defines the default slots for item placement, each linked to a specific bone, position, and rotation.

#### Slot Class Specification

- `bone` (number): The ID of the bone where the slot is attached.
- `pos` (vector3): The position vector (x, y, z) relative to the bone.
- `rot` (vector3): The rotation vector (x, y, z) relative to the bone.

### 2. Back Items Configuration (`BackItems`)

This configuration outlines the properties and placement rules for back items.

#### BackItem Class Overview

- `prio` (number): Sets the display priority of the item.
- `group` (string, optional): Defines the slot group for the item, defaulting to 'back'.
- `customPos` (table, optional): Specifies a custom position for the item, which includes:
  - `bone` (number, optional): The bone ID for custom attachment. **Mandatory if `ignoreLimits` is utilized**.
  - `pos` (vector3, optional): The custom position vector. **Mandatory if `ignoreLimits` is utilized**.
  - `rot` (vector3, optional): The custom rotation vector. **Mandatory if `ignoreLimits` is utilized**.
- `ignoreLimits` (boolean, optional): When true, the item attaches regardless of available slots. **Requires a full `customPos` setup**.
- `model` (number, optional): Necessary for non-weapon items or alternative models for weapons.

## Configuration Examples

### Configuring Default Slots
Define default slots in `Config.defaultSlots`. Example:

```lua
Config.defaultSlots = {
    ['back'] = {
        { bone = 24818, pos = vec3(0.09, -0.16, 0.12), rot = vec3(0.0, 180.0, 0.0) },
        ...
    }
}
```

### Configuring Back Items

- the **index** for the back items should be the same as the **item name** in the inventory

#### Normal Weapon Back Item
```lua
Config.BackItems = {
    ['WEAPON_CARBINERIFLE'] = {
        prio = 3,
        group = 'back'
    },
}
```

#### Normal Non-Weapon Back Item
```lua
Config.BackItems = {
    ['cone'] = {
        prio = 3,
        model = `prop_roadcone02a`,  -- Required model for non-weapons
        group = 'back'
    },
}
```

#### Weapon Back Item with Alternative `model`
```lua
Config.BackItems = {
    ['katana'] = {
        prio = 3,
        model = `sheathed_katana`,  -- Optional alternative model for weapons
        group = 'back'
    },
}
```

#### Weapon Back Item with `customPos`
```lua
Config.BackItems = {
    ['WEAPON_BAT'] = {
        prio = 3,
        group = 'back',
        customPos = {
            pos = { x = 0.4, y = -0.15 },
            rot = { y = 270.0 }
        }
    },
}
```

#### Back Item with `ignoreLimits`

items with `ignoreLimits` will ALWAYS equip when in the inventory. they dont use a slot group or prio, but do require a complete customPos

this is an example of a cone that gets put on your head

```lua
Config.BackItems = {
    ['cone'] = {
        ignoreLimits = true,
        model = `prop_roadcone02a`,
        customPos = {
            bone = 12844,
            pos = vec3(0.06, 0.0, 0.0),
            rot = vec3(0.0, 90.0, 0.0)
        }
    }
}
```

## Customization Guidance

- Ensure correct bone IDs, positions, and rotations for desired item placements.
- Use `ignoreLimits` only with a complete `customPos`.
- The `model` field is required for non-weapon items or alternative weapon models.

---

This updated documentation aims to provide a clear and comprehensive guide for users to effectively configure the `backItems` module with a focus on special cases and requirements.