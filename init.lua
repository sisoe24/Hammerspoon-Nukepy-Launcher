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

--- HNukeLauncher.parseRecursively
--- Constant
--- Parse recursively when iterating over directory
obj.parseRecursively = true

--- HNukeLauncher.pathLenght
--- Variable
--- How long the path should be in the subtext of the chooser 'users/x/path3/path2/path1/. Starts from the end'
obj.pathLenght = 4

--- HNukeLauncher.logger
--- Variable
--- Logging funcionality. Defaults to info
obj.logger = 'info'
local logger = hs.logger.new("NukeLauncher", obj.logger)

scripts = {}

local function launchScript(file)
  -- TODO: App must be taken from all applications lists
  hs.application("Nuke12.2v3"):activate()
  hs.eventtap.keyStroke({"option"}, "x")
  hs.eventtap.keyStrokes(file)
  hs.eventtap.keyStroke({}, "return")
end

obj.chooser = hs.chooser.new(function(choice)
  if choice == nil then return end
  logger.i(choice["path"])
  launchScript(choice["path"])
end)

--- HNukeLauncher.placeholderText
--- Variable
--- Placeholder text for the chooser menu. Defaults to "Nuke scripts launcher"
obj.chooser:placeholderText("Nuke scripts launcher")

--- HNukeLauncher.width
--- Variable
--- Width of the chooser menu. Defaults to 20
obj.chooser:width(20)

-- Internal function that shortens the paath for easier reading in the chooser
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
  local numScripts = #scripts
  local nRows = 10
  logger.v(numFile)
  if numScripts <= 9 then nRows = numScripts end

  obj.chooser:rows(nRows)
end

--- HNukeLauncher:addDirectory(path, HNukeLauncher:parseRecursively)
--- Method
--- Generate chooser entries from python files in the path
---
--- Parameters:
--- path - the path to be parsed for .py files
--- HNukeLauncher:parseRecursively - An optional boolean for recursive parsing
function obj:addDirectory(path, parseRecursively)
  local dirs = {}
  local path = string.gsub(path, '/$', '')
  local shortedPath = shortenPath(path)

  for file in hs.fs.dir(path) do
    if file ~= "." and file ~= ".." then

      local filePath = path .. "/" .. file

      if string.match(file, ".py$") then
        logger.v(file)
        table.insert(scripts, {
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

  obj.chooser:choices(scripts)
  setChooserRows()
end

--- HNukeLauncher:bindHotkeys(mapping)
--- Method
--- Add a hotkey to call the chooser menu
---
--- Parameters:
--- mapping - a table containing the shortcuts keys: {{"ctrl", "shift"}, "f"}
function obj:bindHotkeys(mapping)
  modifiers, keys = table.unpack(mapping)
  hs.hotkey.bind(modifiers, keys, function() obj.chooser:show() end)
end

return obj
