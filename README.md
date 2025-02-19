# nuclear
idk trying to create a game

# File Organisation
## `addons/`
3rd party "addons" or "plugins"
## `assets/`
Contains miscellaneous assets that is not specific to an entity, such as prototyping `textures/`, music, etc.
## `entities/`
Contains everything from the `player/` and enemies, to objects like weapons, items, ui, etc.

> note: maybe `ui` should be it's own folder instead?
## `scenes/`
includes scenes such as the main scene / stage, other stages / prefabs, etc.

does NOT include scenes like `player.tscn` as those are already considered in the `entities/` folder
