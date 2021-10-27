local function prettifyDTRUnit(unit)
  -- This function prettifies a data transfer rate, by making it more readable.
  -- For example mbps becomes 'Mbps (MBit/s)', whereas mbs becomes 'MB/s'
  -- @unit : string
  -- Output: prettified string
  local len = string.len(unit)
  if string.find(unit, 'p') then
    local firstPart = string.upper(string.sub(unit, 1, 1)) ..
                      string.sub(unit, 2, len)
    local secondPart = string.upper(string.sub(unit, 1, string.find(unit, 'p') - 1))
    return firstPart .. ' (' .. secondPart.. 'it/s)'
  end
  local firstPart = string.upper(string.sub(unit, 1, len - 1))
  return firstPart .. '/s'
end

function startsWith(myString, substring)
  -- This function checks if a string begins with another string
  -- @myString: string to check
  -- @substring: substring with which @myString should start
  -- Output: boolean
  return string.sub(myString, 1, string.len(substring)) == substring
end

function string.levenshtein(str1, str2)
-- Returns the Levenshtein distance between the two given strings
-- Taken from https://gist.github.com/Badgerati/3261142
  local len1 = string.len(str1)
  local len2 = string.len(str2)
  local matrix = {}
  local cost = 0
  -- quick cut-offs to save time
  if (len1 == 0) then
    return len2
  elseif (len2 == 0) then
    return len1
  elseif (str1 == str2) then
    return 0
  end
  -- initialise the base matrix values
  for i = 0, len1, 1 do
    matrix[i] = {}
    matrix[i][0] = i
  end
  for j = 0, len2, 1 do
    matrix[0][j] = j
  end
  -- actual Levenshtein algorithm
  for i = 1, len1, 1 do
    for j = 1, len2, 1 do
      if (str1:byte(i) == str2:byte(j)) then
        cost = 0
      else
        cost = 1
      end
      matrix[i][j] = math.min(matrix[i-1][j] + 1, matrix[i][j-1] + 1, matrix[i-1][j-1] + cost)
    end
  end
  -- return the last value - this is the Levenshtein distance
  return matrix[len1][len2]
end

local function findClosestMatch(toCheck, correspondences)
  -- This function finds the closest match of a string in a table of string
  -- using the levenshtein metric for comparison
  -- @toCheck: string to compare with the rest
  -- @correspondences: table of strings used for the comparison
  -- Output: string of @correspondences that is most similar to @toCheck
  local mostSimilarStr = ''
  local mostSimilarScore = 99999
  for _, corr in ipairs(correspondences) do
    for k, _ in pairs(corr) do
      local tempScore = string.levenshtein(toCheck, k)
      if tempScore < mostSimilarScore then
        mostSimilarScore = tempScore
        mostSimilarStr = k
      end
    end
  end
  return mostSimilarStr
end

local function checkOctal(value)
  -- This function takes a string as input and converts it to octal base if
  -- it begins with 0 (but not with 0x (hex) or 0b (binary))
  -- @value: string to check
  -- Output: value or value converted to octal base
  if startsWith(value, '0') and not startsWith(value, '0x') and
    not startsWith(value, '0b') then
    return tonumber(value, 8)
  end
  return value
end

local function computeTwosComplement(binary)
  -- This function takes a string representing a binary number as input
  -- and computes the two's complement of it
  -- @binary: string of the binary number
  -- Output: two's complement of @binary
  local len = string.len(binary)
  local newNumberOfBits = len + 1 + ((4- (len + 1)) % 4)

  for _ = len+1, newNumberOfBits, 1 do
    binary = '0' .. binary
  end

  len = string.len(binary)
  for cnt=len,1,-1 do
    local newBit = ''
    if string.sub(binary, cnt, cnt) == '0' then
      newBit = '1'
    else
      newBit = '0'
    end
    binary = string.sub(binary, 1, cnt-1) .. newBit .. string.sub(binary, cnt + 1, string.len(binary))
  end
  local carriage = 1
  for cnt=len,1,-1 do
    local newBit = ''
    if string.sub(binary, cnt, cnt) == '0' and carriage == 1 then
      newBit = '1'
      carriage = 0
    elseif string.sub(binary, cnt, cnt) == '0' and carriage == 0 then
      goto continue
    elseif string.sub(binary, cnt, cnt) == '1' and carriage == 1 then
      newBit = '0'
    else
      goto continue
    end
    binary = string.sub(binary, 1, cnt-1) .. newBit .. string.sub(binary, cnt + 1, string.len(binary))
    ::continue::
  end
  return binary
end

local function round(num)
  -- This function rounds a float number to the closest integer
  if num - math.floor(num) >= 0.5 then
    return math.ceil(num)
  end
  return math.floor(num)
end

local function convertRgb2Hsl(colors)
  -- This function converts a table with 3 values from RGB to HSL space
  -- @colors: table with 3 values in RGB space
  -- Output: tables with 3 values in HSL space
  for idx=1,3,1 do
    colors[idx] = colors[idx]/255
  end
  local cMax = math.max(colors[1], colors[2], colors[3])
  local cMin = math.min(colors[1], colors[2], colors[3])
  local diff = cMax - cMin
  local hue = 0
  if diff == 0 then
    hue = 0
  elseif cMax == colors[1] then
    hue = 60*((colors[2] - colors[3])/diff % 6)
  elseif cMax == colors[2] then
    hue = 60*((colors[3] - colors[1])/diff + 2)
  -- case if cMax == colors[3]
  else
    hue = 60*((colors[1] - colors[2])/diff + 4)
  end
  local lightness = (cMax + cMin) / 2
  local saturation = diff == 0 and 0 or diff/(1 - math.abs(2*lightness - 1))
  return string.format('hsl(%d, %.1f%%, %.1f%%)', hue, saturation*100, lightness*100)
end

local function convertHsl2Rgb(colors)
  -- This function converts a table with 3 values from HSL to RGB space
  -- @colors: table with 3 values in HSL space
  -- Output: tables with 3 values in RGB space
  local H = colors[1]
  local S = colors[2]/100
  local L = colors[3]/100
  local C = (1 - math.abs(2*L - 1)) * S
  local X = C * (1 - math.abs((H/60) % 2 - 1))
  local m = L - C / 2
  local R = 0
  local G = 0
  local B = 0
  assert(H >= 0 and H <= 360)
  if H < 60 then
    R, G, B = C, X, 0
  elseif H < 120 then
    R, G, B = X, C, 0
  elseif H < 180 then
    R, G, B = 0, C, X
  elseif H < 240 then
    R, G, B = 0, X, C
  elseif H < 300 then
    R, G, B = X, 0, C
  else
    R, G, B = C, 0, X
  end
  return {round((R+m)*255), round((G+m)*255), round((B+m)*255)}
end

return {
  prettifyDTRUnit = prettifyDTRUnit,
  startsWith = startsWith,
  findClosestMatch = findClosestMatch,
  checkOctal = checkOctal,
  computeTwosComplement = computeTwosComplement,
  round = round,
  convertHsl2Rgb = convertHsl2Rgb,
  convertRgb2Hsl = convertRgb2Hsl
}
