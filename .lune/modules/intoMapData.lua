local fs = require("@lune/fs")
local readImage = require("readImage")

local function encodeToCompressedHex(color)
	return string.format("#%x%x%x", color.red / 255 * 16, color.green / 255 * 16, color.blue / 255 * 16)
end

local function intoMapData(mapName)
	local directory = `assets/{mapName}`
	local colorPath = `{directory}/color.png`
	local heightPath = `{directory}/height.png`
	assert(fs.isDir(directory), `Tried converting {mapName}, but no containing directory at {directory}`)
	assert(fs.isFile(colorPath), "Could not find color.png.")
	assert(fs.isFile(heightPath), "Could not find height.png.")

	local colorImage = readImage(colorPath)
	local heightImage = readImage(heightPath)

	assert(colorImage.height == heightImage.height, "Height of images differ!")
	assert(colorImage.width == heightImage.width, "Width of images differ!")

	local width = colorImage.width
	local height = colorImage.height

	local mapData = {}
	
	for y = 1, height do
		local row = table.create(width)

		for x = 1, width do
			row[x] = {
				h = encodeToCompressedHex(colorImage.data[x + (y-1) *height]),
				d = heightImage.data[x + (y-1) *height].red
			}
		end
		
		mapData[y] = row
	end

	return mapData
end

return intoMapData