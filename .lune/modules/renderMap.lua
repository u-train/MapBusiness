--!nocheck
local roblox = require("@lune/roblox")

local function withinSizeLimit(starting, ending)
	return starting - (ending + 1) < 2048
end

local function mergeStudMap(unmergedMap)
	-- This is a list of chunks.
	-- A chunk is defined with (x1, y1), (x2, y2), depth, and color.
	local mergedMap = {}

	-- We need to first keep track of all the studs that have been merged.
	-- We don't want to merge a stud more than once.
	local hits = {}

	local function markAsHit(x, y)
		if hits[y] == nil then
			hits[y] = {}
		end

		hits[y][x] = true
	end

	local function wasHit(x, y)
		return hits[y] and hits[y][x]
	end

	for y = 1, #unmergedMap do
		for x = 1, #unmergedMap[y] do
			-- If it was already merged, then don't do anything.
			if wasHit(x, y) then
				continue
			end

			-- Save the starting position of this new chunk.
			local startingX = x
			local startingY = y

			-- What we're merging.
			local markedDepth = unmergedMap[y][x].d
			local markedColor = unmergedMap[y][x].h

			-- This algorithm works incrementally. We start merging across the x-axis. Then across the y-axis.
			local endingX = x
			local endingY = y

			-- Start across the X
			while
				-- Bounds check here.
				endingX + 1 <= #unmergedMap[endingY]
				-- Make sure the next stud over have matching properties.
				and unmergedMap[endingY][endingX + 1].d == markedDepth
				and unmergedMap[endingY][endingX + 1].h == markedColor
				-- Make sure that the next stud wasn't already merged.
				and not wasHit(endingX + 1, endingY)
				and withinSizeLimit(endingX, endingY) 
			do
				-- Merge the stud in.
				endingX += 1
			end

			-- Then let's go across the Y.
			while endingY + 1 <= #unmergedMap do
				-- We must check every new row to make sure we can merge it.
				-- Let's assume optimistically that it does.
				local matchingRow = true
				local row = unmergedMap[endingY + 1]

				for rowX = startingX, endingX do
					if
						row == nil
						or row[rowX].d ~= markedDepth
						or row[rowX].h ~= markedColor
						or wasHit(rowX, endingY + 1)
						or not withinSizeLimit(startingY, endingY)
					then
						matchingRow = false
						break
					end
				end

				if matchingRow then
					endingY += 1
				else
					break
				end
			end

			-- Mark all of the studs in this chunk as merged.
			for localX = startingX, endingX do
				for localY = startingY, endingY do
					markAsHit(localX, localY)
				end
			end

			table.insert(mergedMap, {
				x1 = startingX,
				y1 = startingY,
				x2 = endingX,
				y2 = endingY,
				d = markedDepth,
				h = markedColor,
			})
			 
			-- We can skip ahead the pixels we know for sure we touched.
			-- x = endingX
		end
	end

	return mergedMap
end

local function map(x, x1, x2, y1, y2)
	assert(x >= x1, "x is less than the lower bound x1")
	assert(x <= x2, "x is higher than the upper bound x2")
	return (((x - x1) / math.abs(x1 - x2)) * math.abs(y1 - y2)) + y1
end

local function round(v, bracket)
	bracket = bracket or 1
	return math.floor(v / bracket + math.sign(v) * 0.5) * bracket
end

local function convertCompressedHex(hex)
	local r = hex:sub(2, 2)
	local g = hex:sub(3, 3)
	local b = hex:sub(4, 4)
	return roblox.Color3.new(tonumber(r, 16) * 16 / 255, tonumber(g, 16) * 16 / 255, tonumber(b, 16) * 16 / 255)
end

local function renderMap(mapData)
	local optimizedMap = mergeStudMap(mapData)

	print(#optimizedMap)

	local root = roblox.Instance.new("Model")
	root.Name = "Map"

	for _, run in optimizedMap do
		local part = roblox.Instance.new("Part")
		part.Color = convertCompressedHex(run.h)

		local mappedHeight = round(map(run.d, 0, 255, 1, 65), 0.5)
		local width = run.x2 - run.x1 + 1
		local height = run.y2 - run.y1 + 1

		part.Size = roblox.Vector3.new(width, mappedHeight, height)
		part.CFrame = roblox.CFrame.new(run.x1 + width / 2, mappedHeight / 2, run.y1 + height / 2)
		part.Parent = root
	end

	return root
end

return renderMap
