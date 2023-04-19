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
	
	if not tonumber(self:peek()) then
		error(`Expected number, got {self:peek()}`)
	end

	local result = ""

	while not self:endOfBuffer() and tonumber(self:peek()) do
		result ..= self:chew()
	end

	local mustBeNumber = assert(tonumber(result), "Cannot fail")

	return mustBeNumber
end

function Parser:whitespace()
	if self:endOfBuffer() then
		error("Expected whitespace at end of buffer.")
	end

	if not string.find(self:peek(), "%s") then
		error(`Expected whitespace, got {self:peek()}`)
	end

	while not self:endOfBuffer() and string.find(self:peek(), "%s") do
		self:chew()
	end

	return true
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

	image.data = {}

	while not blob:endOfBuffer() do
		local red = blob:number()
		blob:whitespace()
		local green = blob:number()
		blob:whitespace()
		local blue = blob:number()
		blob:whitespace()
		
		table.insert(image.data, {red = red, green = green, blue = blue})
	end

	return image
end

return parsePPM