local parsePPM = require("parsePPM")

local function readImage(image)
	local result = process.spawn("convert", {
		"-compress",
		"none",
		image,
		"PPM:-",
	})

	if result.ok then
		local ppmImage = parsePPM(result.stdout)
		return ppmImage
	else
		error(`Wasn't able to read image ({image}) because: \n {result.stderr}`)
	end
end

return readImage
