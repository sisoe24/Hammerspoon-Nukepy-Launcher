--- === HNukeLauncher ===
---
--- Create a chooser menu with python files to be launched in Nuke app.
---
--- Download: [https://github.com/Hammerspoon/Spoons/raw/master/Spoons/PopupTranslateSelection.spoon.zip](https://github.com/Hammerspoon/Spoons/raw/master/Spoons/PopupTranslateSelection.spoon.zip)
local obj = {}
obj.__index = obj

-- Metadata
obj.name = "HNukeLauncher"
obj.version = "0.1"
obj.author = "Virgil Sisoe <virgilsisoe@gmail.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

--- HNukeLauncher.pathLenght
--- Variable
--- How long the path should be in the subtext of the chooser 'users/x/path3/path2/path1/. Starts from the end'
obj.pathLenght = 4

--- HNukeLauncher.logger
--- Variable
--- Logging funcionality. Defaults to info
obj.logger = 'info'
local logger = hs.logger.new("NukeLauncher", obj.logger)

SCRIPTS = {}

-- TODO: maybe add change to add specific window app by user
function checkApp()
  local app, secondWindow = hs.application.find("Nuke.+")

  if secondWindow then 
    hs.alert("Multiple windows detected. Scripts does not know which one you want. Aborting")
    return nil
  end

  if app == nil or app:mainWindow() == nil then
    hs.alert("Application window not detected. Please try again")
    return nil
  end

  return app
end

local function launchScript(file)
  local app = checkApp()
  if not app then return end

  app:activate()
  hs.eventtap.keyStroke({"option"}, "x")
  hs.eventtap.keyStrokes(file)
  hs.eventtap.keyStroke({}, "return")
end

-- internal function that updates the script list
-- putting the last selected item at the top of the list
local function updateChooserList(choice)
  local popItem = ""

  for index, _table in pairs(SCRIPTS) do
    if hs.fnutils.indexOf(_table, choice['text']) then
      popItem = table.remove(SCRIPTS, index)
    end
  end

  table.insert(SCRIPTS, 1, popItem)
  MenuChooser:choices(SCRIPTS)
end

MenuChooser = hs.chooser.new(function(choice)
  if choice == nil then return end
  logger.i(choice["path"])
  launchScript(choice["path"])
  updateChooserList(choice)
end)

MenuChooser:placeholderText("Nuke launcher script")

MenuChooser:rightClickCallback(function(choice)
  local path = MenuChooser:selectedRowContents(choice)['path']
  hs.execute(string.format("open \"%s\"", path))
end)

MenuChooser:width(15)

-- Internal function that shortens the path for easier reading in the chooser
local function shortenPath(path)
  local splittedPath = hs.fnutils.split(path, "/")
  local newPath = ".../"

  local pathEnd = #splittedPath - obj.pathLenght

  for index, path in pairs(splittedPath) do
    if string.match(path, '.+') then
      if index > pathEnd then newPath = newPath .. path .. "/" end
    end
  end
  return newPath
end

-- Internal function that sets the rows of the chooser based
-- on the numbers of files
local function setChooserRows()
  local numSCRIPTS = #SCRIPTS
  local nRows = 10
  logger.v(numFile)
  if numSCRIPTS <= 9 then nRows = numSCRIPTS end

  MenuChooser:rows(nRows)
end

-- Internal Function.
-- Parse directories searching for .py files
-- and create a valid entry for the chooser menu
--
-- Parameters:
-- path - path to be parsed
-- parseRecursively - optional boolean to parse recursively
function parseDirectories(path, parseRecursively)
  local dirs = {}
  local path = string.gsub(path, '/$', '')
  local shortedPath = shortenPath(path)

  for file in hs.fs.dir(path) do
    if file ~= "." and file ~= ".." then

      local filePath = path .. "/" .. file

      if string.match(file, ".py$") then
        logger.v("valid py file:", file)
        table.insert(SCRIPTS, {
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

  for k, v in pairs(dirs) do obj:addDirectory(v, parseRecursively) end

  MenuChooser:choices(SCRIPTS)
  setChooserRows()
end

--- HNukeLauncher:addDirectory(path, HNukeLauncher:parseRecursively)
--- Method
--- Generate chooser entries from python files in the path
---
--- Parameters:
--- path - the path to be parsed for .py files
--- arseRecursively - An optional boolean for recursive parsing
function obj:addDirectory(path, parseRecursively)
  parseDirectories(path, parseRecursively)
end

--- HNukeLauncher:bindHotkeys(mapping)
--- Method
--- Add a hotkey to call the chooser menu
---
--- Parameters:
--- mapping - a table containing the shortcuts keys: {{"ctrl", "shift"}, "f"}
function obj:bindHotkeys(mapping)
  modifiers, keys = table.unpack(mapping)
  hs.hotkey.bind(modifiers, keys, function() MenuChooser:show() end)
end

return obj
