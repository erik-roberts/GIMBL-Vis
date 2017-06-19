![GIMBL-Vis](/docs/gvLogo.jpg)

## Implementation Details
All GV objects are handle objects.

Internally, the `gv` object is primarily composed of `gvModel`, `gvView`, and `gvController` objects, in order loosely follow a Model-View-Controller (MVC) design.

A core aspect of GV is its extensibility via plugins. Plugins are stored in the 'src/plugins' directory as `classdef` files or folders (i.e. folders starting with '@'). Plugins derive from abstract plugin classes. Non-gui plugins inherit from `gvPlugin`. Gui plugins without a separate window inherit from `gvGuiPlugin`, while those that open a separate window inherit from `gvWindowPlugin`.

With the MVC, GV losely follows an observer pattern. The observer objects (i.e. events, callbacks, and listeners) are stored in the gvController whenever possible. However, plugin-specific observer objects are stored in the plugin objects. These observer objects should interact with the existing `gvController` observer objects as much as possible.

Each `hypercube` dataset is stored as a field of the `gvModel` `data` structure property. The field name corresponds to the `hypercube` name. Each `hypercube` dataset is stored in a `gvArray`, which is a subclass of the MultiDimensional Dictionary ([`MDD`](https://github.com/davestanley/MultiDimensionalDictionary)) class. The `gvArray` class replaces the default `MDDAxis` objects from `MDD` with a `gvArrayAxis` subclass of `MDDAxis`.

## Coding Conventions
- Class properties are either public or read-only (i.e. `SetAccess = protected`). Thus they are never private to allow for easier development. If a property is read-only, there is typically a public method for setting it. Class methods are either public or protected. Unlike properties, methods can have side-affects, so they may be protected. They should be protected instead of private to allow for subclass inheritance. Properties and methods are never hidden to aid development. The `gv` class is an exception to these guidelines to avoid unintentional user interaction. The prefered user CLI interaction is through the `gvObject.cli` object.

## Naming Conventions
- classes are prefixed with `gv` followed by UpperCamelCase
- object methods are lowerCamelCase
- static/class methods use UpperCamelCase
- `make` instead of `create`
- Callbacks use `Callback_` prefix followed by lowerCamelCase:
  - general: `Callback_callbackName`
  - events: `Callback_eventName`
  - matlab objects: `Callback_tagName`
- Tags:
  - Main Window Tabs: `[pluginObj.pluginFieldName '_window_tab_' thisPlugin.pluginName];`
  - Main Window Panels (i.e. Controls in Tab): `[pluginObj.pluginFieldName '_panel_' thisTagStr]`
  - Window Figure: `[pluginObj.pluginFieldName '_window']`
  - Window Controls: `[pluginObj.pluginFieldName '_window_' thisTagStr];`
  - Window Menu Items:
    - For Col: `[pluginObj.pluginFieldName '_menu_' menuHandleStr]`
    - For Row: `[pluginObj.pluginFieldName '_menu_' menuHandleStr '_' handleStr]`
