# DRAG CRAFT

crafting system using `ox_inventory`. The crafting system allows users to create new items by dragging and combining items in their own inventory.

## Usage

To create a new item, follow the structure of the `RECIPES` table and add a new entry. Each entry consists of the following properties:

- `duration`: The duration in milliseconds for the craft to complete.
- `result`: An array of objects representing the resulting items after the craft. Each object should have a `name` property specifying the item's name and an `amount` property indicating the quantity obtained.
- `costs`: A table that specifies the amount of both items needed to perform the craft and whether they should be removed upon completion. Each item is represented as a key-value pair, where the key is the item's name and the value is a table with `need` and `remove` properties. The `need` property specifies the required quantity, and the `remove` property indicates whether the item should be removed from the inventory upon completion.

You can add as many different item/amount pairs to the `result` array as desired, allowing for multiple items to be obtained from a single craft.

```lua
RECIPES = {
    ['garbage scrapmetal'] = { --'item1 item2' this is the 2 items that will be dragged ontop of eachother seperated by a single space
        duration = 2000,
        result = {
            {name = 'lockpick', amount = 1},
        },
        costs = {
            ['garbage'] = {need = 1, remove = false},
            ['scrapmetal'] = {need = 1, remove = true},
        },
    },
    -- Add more craft recipes here
}
```

## Notes

- Ensure that the item names used in the `RECIPES` table match the item names in `ox_inventory`.
