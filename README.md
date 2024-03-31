**THIS IS NOT AN OFFICIAL OVEREXTENDED SCRIPT**

# ox_inventory_addons

This resource enhances gameplay experience by providing several modules that utilize ox_inventory hooks. Each module adds unique features.

## Modules

### backItems

The `backItems` module allows you to add items to a list that will appear attached to your character when the corresponding item is in your inventory.

 - client objects synced via statebags
 - full attachment and skin support
 - persistent flashlights through item metadata
 - supports alt models for weapons. i.e. katana weapon w/ sheath model on back
 - supports non-weapon items as well. drugs, money, etc.
 

#### thanks to [Zoo](https://github.com/FjamZoo) and others who worked on [Renewed-Weaponscarry](https://github.com/Renewed-Scripts/Renewed-Weaponscarry) I was able to use some things from here to write this module.

[backItems.md](./backItems/backItems.md)

### dragCraft

The `dragCraft` module enables the creation of crafting recipes triggered by dragging two items on top of each other in the inventory.
This intuitive system simplifies the crafting process and adds an interactive element to the inventory.

[dragCraft.md](./dragCraft/dragCraft.md)

### itemCarry

The `itemCarry` module allows you to define items in a list that your character will physically carry and play an animation when the corresponding item enters your inventory.

[itemCarry.md](./itemCarry/itemCarry.md)

## Getting Started

1. Clone or download this repository.
2. Place the resource into your FiveM server's `resources` directory.
3. Add `ox_inventory_addons` to your `server.cfg` file to ensure the resource is started when the server boots up.
4. Customize the module configurations as per your preferences by editing the respective module files.

## Dependencies

1. ox_lib
2. ox_inventory

## Support and Contribution

For any issues, questions, or feedback, please open an issue on the [GitHub repository](https://github.com/Demigod916/ox_inventory_addons). Contributions and pull requests may also be considered.

## License

This project is licensed under the [GPL-3.0 License](./LICENSE).

Feel free to do whatever with the code, just credit me.
