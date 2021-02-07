# [docs](index.md) » HNukeLauncher

---

Create a chooser menu with python files to be launched inside Nuke app.
![chooser](/Spoons/HNukeLauncher.spoon/images/chooser.png)

HNukeLauncher uses [applescript idea](https://github.com/sisoe24/Nukepy-Applescript-Launcher) to execute actions.

## Basic usage

Download: [https://github.com/sisoe24/Hammerspoon-Nukepy-Launcher/releases/download/0.0.1/HNukeLauncher.spoon.zip](https://github.com/sisoe24/Hammerspoon-Nukepy-Launcher/releases/download/0.0.1/HNukeLauncher.spoon.zip)

---
**NOTE**
If you unzip the file with tools other than the default, be sure that the file name still has the .spoon at the end (_HNukeLauncher.spoon_), otherwise it will be threated like any other folder.

---

Unzip the file and double clicking on the .spoon file to install, then inside your _init.lua_:

```lua
nuke = hs.loadSpoon("HNukeLauncher")
nuke:bindHotkeys({{"ctrl", "shift"}, "z"})     -- add hotkey
nuke:addDirectory("/path/to/nuke_scripts")     
nuke:addDirectory("/other/path/scripts", true) -- parse recursevily inside path
nuke:returnFocus = false                       -- do not return focus on starting app
```

## API Overview

* Variables - Configurable values
  * [logger](#logger)
  * [pathLength](#pathLength)
  * [returnFocus](#returnFocus)
* Methods - API calls which can only be made on an object returned by a constructor
  * [addDirectory](#addDirectory)
  * [bindHotkeys](#bindHotkeys)

## API Documentation

### Variables

| [logger](#logger) |                                         |
| ----------------- | --------------------------------------- |
| **Signature**     | `HNukeLauncher.logger`                  |
| **Type**          | Variable                                |
| **Description**   | Optional. Logging functionality. Defaults to info |

| [pathLength](#pathLength) |                                                                                                             |
| ------------------------- | ----------------------------------------------------------------------------------------------------------- |
| **Signature**             | `HNukeLauncher.pathLength`                                                                                  |
| **Type**                  | Variable                                                                                                    |
| **Description**           | Optional. How long the path should be in the subtext of the chooser `users/x/path3/path2/path1/`. <br>Starts from the end. Defaults to 4. |

| [returnFocus](#returnFocus) |                                                                                             |
| --------------------------- | ------------------------------------------------------------------------------------------- |
| **Signature**               | `HNukeLauncher.returnFocus`                                                                 |
| **Type**                    | Variable                                                                                    |
| **Description**             | Optional. Return the focus to the app which is currenlty active when the script launcher is executed. <br>Defaults to `true`|

### Methods

| [addDirectory](#addDirectory) |                                                                                                                                  |
| ----------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| **Signature**                 | `HNukeLauncher:addDirectory(path, parseRecursively)`                                                               |
| **Type**                      | Method                                                                                                                           |
| **Description**               | Generate chooser entries from python files in the path                                                                           |
| **Parameters**                | <ul><li>path - the path to be parsed for .py files</li><li>parseRecursively - An optional boolean for recursive parsing</li></ul> |

| [bindHotkeys](#bindHotkeys) |                                                                                             |
| --------------------------- | ------------------------------------------------------------------------------------------- |
| **Signature**               | `HNukeLauncher:bindHotkeys(mapping)`                                                        |
| **Type**                    | Method                                                                                      |
| **Description**             | Add a hotkey to call the chooser menu                                                       |
| **Parameters**              | <ul><li>mapping - a table containing the shortcuts keys: {{"ctrl", "shift"}, "f"}</li></ul> |
