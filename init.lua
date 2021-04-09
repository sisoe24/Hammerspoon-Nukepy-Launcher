--- === HNukeLauncher ===
---
--- Create a chooser menu with python files to be launched in Nuke app.
---
--- Download: [https://github.com/sisoe24/Hammerspoon-Nukepy-Launcher/releases/download/0.0.1/HNukeLauncher.spoon.zip](https://github.com/sisoe24/Hammerspoon-Nukepy-Launcher/releases/download/0.0.1/HNukeLauncher.spoon.zip)
local obj = {}
obj._index = obj

-- Metadata
obj.name = "HNukeLauncher"
obj.version = "0.1"
obj.author = "Virgil Sisoe <virgilsisoe@gmail.com>"
obj.homepage = "https://github.com/sisoe24/Hammerspoon-Nukepy-Launcher"
obj.license = "MIT - https://opensource.org/licenses/MIT"

--- HNukeLauncher.returnFocus
--- Variable
--- Optional. Return the focus to the app which is currenlty active when the script launcher is executed.
obj.returnFocus = true

--- HNukeLauncher.pathLength
--- Variable
--- Optional. How long the path should be in the subtext of the chooser 'users/x/path3/path2/path1/. Starts from the end. Defaults to 4'
obj.pathLength = 4

--- HNukeLauncher.logger
--- Variable
--- Optional. Logging functionality. Defaults to info
obj.logger = 'info'
local logger = hs.logger.new("NukeLauncher", obj.logger)

obj._SCRIPTS = {}

-- TODO: maybe add change to add specific window app by user
function _checkApp()
  local app, secondWindow = hs.application.find("Nuke.+")

  if secondWindow then
    hs.alert("Multiple windows. Scripts does not know which one you want.")
    return nil
  end

  if not app or not app:mainWindow() then
    hs.alert("Application window not detected")
    return nil
  end

  local currentApp = hs.application.frontmostApplication()
  return app, app:mainWindow(), currentApp
end

-- Internal function
-- Launch the select .py file inside nuke
function obj:launchScript(file)
  local app, window, currentApp = _checkApp()
  if not app then return end

  app:activate()
  local execute = string.format([[
    tell application "System Events"
      tell process "%s"
        click menu item "Scripting" of menu 1 of menu bar item "Workspace" of menu bar 1
        click button 4 of group 1 of splitter group 2 of splitter group 1 of window "%s"
        delay 0.1
        set value of text field 1 of window "Choose a script file" to "%s"
        delay 0.05
        click button "Open" of window "Choose a script file"
      end tell
    end tell
  ]], app:name(), window:title(), file)

  local a, b, c = hs.osascript.applescript(execute)
  logger:d('applescript report:', a, b, c)

  if self.returnFocus then currentApp:activate() end

end

-- Internal function
-- Updates the script list by putting the last selected item at the top of the list
function obj:updateChooserList(choice)
  local popItem = ""

  for index, _table in pairs(self._SCRIPTS) do
    if hs.fnutils.indexOf(_table, choice['text']) then
      popItem = table.remove(self._SCRIPTS, index)
    end
  end

  table.insert(obj._SCRIPTS, 1, popItem)
  obj.MenuChooser:choices(obj._SCRIPTS)
end

-- TODO: update with self
obj.MenuChooser = hs.chooser.new(function(choice)
  if choice == nil then return end
  logger.i(choice["path"])
  obj:launchScript(choice["path"])
  obj:updateChooserList(choice)
end)

obj.MenuChooser:placeholderText("Nuke launcher script")
obj.MenuChooser:rightClickCallback(function(choice)
  local path = obj.MenuChooser:selectedRowContents(choice)['path']
  hs.execute(string.format("open \"%s\"", path))
end)

obj.MenuChooser:width(15)

-- Internal function
-- Shorten the path for easier reading in the chooser
function obj:shortenPath(fullPath)
  local splittedPath = hs.fnutils.split(fullPath, "/")
  local newPath = ".../"

  local pathEnd = #splittedPath - self.pathLength

  for index, path in pairs(splittedPath) do
    if string.match(path, '.+') then
      if index > pathEnd then newPath = newPath .. path .. "/" end
    end
  end
  return newPath
end

-- Internal function that sets the rows of the chooser based
-- on the numbers of files
function obj:setChooserRows()
  local numScripts = #self._SCRIPTS
  logger.v(numScripts)

  local nRows = 10
  if numScripts <= 9 then nRows = numScripts end

  self.MenuChooser:rows(nRows)
end

-- Internal Function.
-- Parse directories searching for .py files
-- and create a valid entry for the chooser menu
--
-- Parameters:
-- path - path to be parsed
-- parseRecursively - optional boolean to parse recursively
function obj:parseDirectories(path, parseRecursively)
  local dirs = {}
  path = string.gsub(path, '/$', '')
  local shortedPath = self:shortenPath(path)

  for file in hs.fs.dir(path) do
    if file ~= "." and file ~= ".." then

      local filePath = path .. "/" .. file

      if string.match(file, ".py$") then
        logger.v("valid py file:", file)
        table.insert(obj._SCRIPTS, {
          ['text'] = file,
          ['subText'] = shortedPath,
          ["path"] = filePath
        })
      end

      local fileAttr = hs.fs.attributes(filePath).mode
      if parseRecursively then
        if fileAttr == "directory" then table.insert(dirs, filePath) end
      end

    end
  end

  for _, dir in pairs(dirs) do self:addDirectory(dir, parseRecursively) end

  self.MenuChooser:choices(self._SCRIPTS)
  self:setChooserRows()
end

--- HNukeLauncher:addDirectory(path, parseRecursively)
--- Method
--- Generate chooser entries from python files in the path
---
--- Parameters:
--- path - the path to be parsed for .py files
--- parseRecursively - An optional boolean for recursive parsing
function obj:addDirectory(path, parseRecursively)
  self:parseDirectories(path, parseRecursively)
end

function obj:showChooser() self.MenuChooser:show() end

--- HNukeLauncher:bindHotkeys(mapping)
--- Method
--- Add a hotkey to call the chooser menu
---
--- Parameters:
--- mapping - a table containing the shortcuts keys: {{"ctrl", "shift"}, "f"}
function obj:bindHotkeys(mapping)
  local actions = {chooser = hs.fnutils.partial(self.showChooser, self)}
  hs.spoons.bindHotkeysToSpec(actions, mapping)
end

return obj
