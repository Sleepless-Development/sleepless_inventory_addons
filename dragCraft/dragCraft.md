# DRAG CRAFT

crafting system using `ox_inventory`. The crafting system allows users to create new items by dragging and combining items in their own inventory.

## Usage

To create a new item, follow the structure of the `RECIPES` table and add a new entry. Each entry consists of the following properties:

- `duration`: The duration in milliseconds for the craft to complete.
- `client`: Contains client-side functions to be executed `before` and `after` crafting.
- `server`: Contains server-side functions to be executed `before` and `after` crafting.
- `result`: An array of objects representing the resulting items after the craft. Each object should have a `name` property specifying the item's name and an `amount` property indicating the quantity obtained.
- `costs`: A table that specifies the amount of both items needed to perform the craft and whether they should be removed upon completion. Each item is represented as a key-value pair, where the key is the item's name and the value is a table with `need` and `remove` properties. The `need` property specifies the required quantity or durability removal amount if between 0.0 and 1.0, and the `remove` property indicates whether the item should be removed from the inventory upon completion.

You can add as many different item/amount pairs to the `result` array as desired, allowing for multiple items to be obtained from a single craft.

```lua
RECIPES = {
    ['garbage scrapmetal'] = { --'item1 item2' this is the 2 items that will be dragged ontop of eachother seperated by a single space
        duration = 2000,
        client = {
            before = function(recipeData) --recipeData is all the info defined here for this specific recipe.
                -- some client logic to run before crafting
                -- if this returns false, it will cancel the craft
                -- returning true or nil will continue with the craft
            end,
            after = function(recipeData)
                -- some client logic to run after successfully crafting
            end,
        },
        server = {
            before = function(recipeData)
                -- some server logic to run before crafting
                -- if this returns false, it will cancel the craft
                -- returning true or nil will continue with the craft
            end,
            after = function(recipeData)
                -- some server logic to run after successfully crafting
            end,
        },
        costs = {
            ['garbage'] = {need = 1, remove = true}, --removes 10% durability everytime its used in a craft. so this would allow 10 uses. 10 * 10 = 100
            ['scrapmetal'] = {need = 0.1, remove = true},
        },
        result = {
            {name = 'lockpick', amount = 1},
        },
    },
    -- Add more craft recipes here
}
```

## Notes

- Ensure that the item names used in the `RECIPES` table match the item names in `ox_inventory`.
