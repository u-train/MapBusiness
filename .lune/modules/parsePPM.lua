local Parser = {}
Parser.__index = Parser

function Parser.new(blob)
	return setmetatable({ _blob = blob, cursor = 1 }, Parser)
end

function Parser:peek()
	return self._blob:sub(self.cursor, self.cursor)
end

function Parser:chew()
	if self.cursor > #self._blob then
		return nil
	end

	local byte = self:peek()
	self.cursor += 1
	return byte
end

function Parser:endOfBuffer()
	return self.cursor > #self._blob
end

function Parser:number()
	if self:endOfBuffer() then
		error("Expected number at end of buffer.")
	end

	local start, ending = string.find(self._blob, "%d+", self.cursor)
	if start ~= self.cursor then
		error(`Expected number, got {self:peek()}`)
	end

	local result = tonumber(self._blob:sub(start, ending))
	self.cursor = ending + 1

	return result
end

function Parser:whitespace()
	if self:endOfBuffer() then
		error("Expected whitespace at end of buffer.")
	end

	local start, ending = string.find(self._blob, "%s+", self.cursor)
	if start ~= self.cursor then
		error(`Expected whitespace, got {self:peek()}`)
	end

	self.cursor = ending + 1

	return true
end

function Parser:color()
	if self:endOfBuffer() then
		error("Expected whitespace at end of buffer.")
	end

	local start, ending, red, green, blue = string.find(self._blob, "(%d+)%s+(%d+)%s+(%d+)%s+", self.cursor)
	if start ~= self.cursor then
		error(`Expected whitespace, got {self:peek()}`)
	end

	self.cursor = ending + 1

	return { red = tonumber(red), green = tonumber(green), blue = tonumber(blue) }
end
local function parsePPM(blob)
	blob = Parser.new(blob)

	local image = {}

	assert(blob:chew() == "P", "Magic number")
	assert(blob:chew() == "3", "Magic number")

	image.magicNumber = "P3"
	blob:whitespace()
	image.width = blob:number()
	blob:whitespace()
	image.height = blob:number()
	blob:whitespace()
	image.maximumValue = blob:number()
	blob:whitespace()

	image.data = table.create(image.width * image.height)

	while not blob:endOfBuffer() do
		table.insert(image.data, blob:color())
	end

	return image
end

return parsePPM
