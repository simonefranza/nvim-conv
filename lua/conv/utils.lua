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

local function startsWith(myString, substring)
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

return {
  prettifyDTRUnit = prettifyDTRUnit,
  startsWith = startsWith,
  findClosestMatch = findClosestMatch,
  checkOctal = checkOctal,
  computeTwosComplement = computeTwosComplement
}
