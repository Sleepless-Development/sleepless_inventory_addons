# Back Items

## Configuration Variables

The following configuration variables are defined:

- `BACK_ITEM_LIMIT`: Specifies the maximum number of back items that can be equipped. The default value is `3`.

- `BACK_ITEM_SLOTS_DEFAULT`: Defines the default settings for each back item slot. It is a table containing three entries, each representing a slot number. Each slot has the following properties:
  - `backData`: Indicates whether back data is enabled for the slot (boolean value).
  - `defaultoffset`: Specifies the default offset for the back item on the slot.

- `BACK_ITEMS`: Contains the configuration for various back items. Each back item is represented by a key-value pair. The key is a string representing the item's identifier, and the value is a table representing the item's properties. The available properties for each back item are as follows:

  - `prio` (mandatory): Specifies the priority of the item. Items with higher priority values will be take priority on being displayed.

  - `ignoreLimits` (optional): Indicates whether the item should be exempted from the back item limit defined by `BACK_ITEM_LIMIT`. It is a boolean value.

  - `model` (required for non-weapon models): Specifies the model of the non-weapon item. It should be the hash value of the model.

  - `hash` (required for weapons): Specifies the hash value of the weapon.

  - `isWeapon`: Indicates whether the item is a weapon (boolean value).

  - `customPos` (optional, but mandatory when `ignoreLimits` is used): Contains custom position and rotation data for the item. It is a table with the following properties:
    - `pos`: Specifies the position of the item as a vector3 (x, y, z).
    - `rot`: Specifies the rotation of the item as a vector3 (x, y, z).
    - `bone`: Specifies the bone to attach the item to (optional).
    - `overrideDefaultZ`: Indicates whether to override the default Z position (optional).

## Adding New Items

To add new items, follow the structure of the existing items in the `BACK_ITEMS` table. Here is an example of adding a new item with default values:

```lua
['NEW_ITEM'] = {
    prio = 1,
    isWeapon = false,
    model = joaat('new_item_model'),
    customPos = {
        pos = vec3(0.0, 0.0, 0.0),
        rot = vec3(0.0, 0.0, 0.0)
    }
}
```

In this example, we've added a new item called 'NEW_ITEM'. Here are the properties used:

- `prio`: The priority of the item is set to 1.
- `isWeapon`: Since this is not a weapon, we set it to `false`.
- `model`: We specify the model of the new item using the `model` property. Replace `new_item_model` with the appropriate hash value for the desired model.
- `customPos`: We provide custom position and rotation data for the item. The `pos` property is set to the default position (0.0, 0.0, 0.0), and the `rot` property is set to the default rotation (0.0, 0.0, 0.0).

You can modify the values of the properties based on your needs. Remember to replace `new_item_model` with the correct

 hash value for the desired model.

Save the changes and run the code with the new item configuration.
