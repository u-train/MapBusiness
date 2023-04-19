local roblox = require("@lune/roblox")
local process = require("@lune/process")
local intoMapData = require("modules/intoMapData")
local renderMap = require("modules/renderMap")

local target = process.args[1]
assert(target, "Expected one argument, the map to build.")

print("Reading and parsing map data...")
local mapData = intoMapData(target)

print("Rendering map into a model.")
local model = renderMap(mapData)

print("Final preparations for the final build.")
local game = roblox.Instance.new("DataModel")
local workspace = game:GetService("Workspace")

model.Parent = workspace

print("Writing place file out...")
roblox.writePlaceFile(`.build/{target}.rbxl`, game)

print("Done! Check in .build folder.")