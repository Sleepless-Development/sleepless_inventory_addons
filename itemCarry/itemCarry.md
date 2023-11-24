# Automatic Item Carrying Script for ox_inventory

This script is used to automatically carry items when using `ox_inventory` in your FiveM resource. By adding entries to the `CARRY_ITEMS` table, you can define the animations, prop models, and placement positions for different items that your players can carry.

## Adding New Entries to CARRY_ITEMS

To add a new entry to the `CARRY_ITEMS` table in your Lua script, follow the structure provided below:

```lua
CARRY_ITEMS = {
    ['item_name'] = {
        dictionary = 'animation_dictionary',
        animation = 'idle',
        walkOnly = true,
        blockVehicle = true,
        flag = 51,
        prop = {
            bone = 60309,
            model = joaat('hei_prop_heist_box'),
            placement = {
                pos = vector3(0.025000, 0.080000, 0.255000),
                rot = vector3(-145.000000, 290.000000, 0.000000),
            },
        },
    },
}
```

- `item_name`: The name of the inventory item. This will be used as the key in the `CARRY_ITEMS` table. NOTE: CARRY ITEMS SHOULD NOT STACK
- `dictionary`: The name of the animation dictionary associated with the item.
- `walkOnly?`: weather or not you want the player to only be able to walk while carrying this item.
- `walkOnly?`: weather or not you want the player to not be able to get in a vehicle with this item.
- `animation`: The name of the animation associated with the item.
- `flag?`: The animation flag value for the item. This determines the behavior of the item when carried.
- `bone_id`: The bone ID on the player's character model where the prop will be attached.
- `prop_model`: The model name of the prop that represents the item.
- `pos`: The position coordinates relative to the bone where the prop will be placed.
- `rot`: The rotation angles for the prop in the X, Y, and Z axes.

Make sure to maintain the indentation and syntax rules of the existing `CARRY_ITEMS` table for consistency.

### Example Usage

Let's say you want to add a new item called 'briefcase' to the `CARRY_ITEMS` table. Here's how the entry might look:

```lua
CARRY_ITEMS = {
    ['box'] = {
        animation = 'idle',
        dictionary = 'anim@heists@box_carry@',
        animationFlag = 51,
        prop = {
            bone = 60309,
            model = 'hei_prop_heist_box',
            placement = {
                pos = vector3(0.025000, 0.080000, 0.255000),
                rot = vector3(-145.000000, 290.000000, 0.000000),
            },
        },
    },
    ['briefcase'] = {
        animation = 'idle',
        dictionary = 'anim@heists@briefcase@',
        animationFlag = 52,
        prop = {
            bone = 60310,
            model = 'prop_briefcase_02',
            placement = {
                pos = vector3(0.035000, 0.070000, 0.240000),
                rot = vector3(-135.000000, 280.000000, 0.000000),
            },
        },
    },
}
```

Ensure that the new entry is added within the existing `CARRY_ITEMS` table in `itemCarry/server/data`, maintaining the comma separation between entries.
