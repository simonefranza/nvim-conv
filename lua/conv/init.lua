local function startsWith(myString, substring)
  return string.sub(myString, 1, string.len(substring)) == substring
end

local function computeTwosComplement(binary)
  local len = string.len(binary)
  local newNumberOfBits = len + 1 + ((4- (len + 1)) % 4)

  for cnt = len+1, newNumberOfBits, 1 do
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

local function convertToBin(param)
  local isNegative = false
  if string.sub(param,1,1) == '-' then
    isNegative = true
    param = string.sub(param, 2, string.len(param))
  end

  local number = tonumber(param) 
  if startsWith(param, '0') and not startsWith(param, '0x') and 
    not startsWith(param, '0b') then
      number = tonumber(param, 8)
  end
  local numBits = math.floor(math.log(number)/math.log(2))
  local outputStr = ""
  for cnt=0,numBits,1 do
    outputStr = bit.rshift(bit.band(number, bit.lshift(1, cnt)), cnt) .. outputStr
  end
  if isNegative then
    outputStr = computeTwosComplement(outputStr)
    param = '-' .. param
  end
  print(string.format('%s = 0b%s', param, outputStr))
end


local function convertToHex(param)
  local initPar = param
  if startsWith(param, '0') and not startsWith(param, '0x') and 
    not startsWith(param, '0b') then
      param = tonumber(param, 8)
  end
  print(string.format("%s = 0x%X", initPar, param))
end

local function convertToOct(param)
  local initPar = param
  if startsWith(param, '0') and not startsWith(param, '0x') and 
    not startsWith(param, '0b') then
      param = tonumber(param, 8)
  end
  print(string.format("%s = 0%o", initPar, param))
end

-- Add with separated bytes
local function convertToStr(param)
  local strRes = ""
  for idx=1,string.len(param)-1,2 do
    strRes = strRes .. string.char(tonumber(string.sub(param, idx, idx + 1), 16))
  end
  print(string.format("%s = %s", param, strRes))
end

local function convertToDecimal(param)
  local initPar = param
  if startsWith(param, '0') and not startsWith(param, '0x') and 
    not startsWith(param, '0b') then
      param = tonumber(param, 8)
  end
  print(string.format("%s = %d", initPar, param))
end


local function parseMode(mode, param)
  local dict = {
              dec = convertToDecimal, 
              hex = convertToHex,
              bin = convertToBin,
              oct = convertToOct,
              str = convertToStr
            }
  dict[mode](param)
end

local function setup()
  {
    vim.cmd("command! -nargs=1 ConvBin lua require('conv.init').parseMode('bin', <f-args>)")
    vim.cmd("command! -nargs=1 ConvDec lua require('conv.init').parseMode('dec', <f-args>)")
    vim.cmd("command! -nargs=1 ConvHex lua require('conv.init').parseMode('hex', <f-args>)")
    vim.cmd("command! -nargs=1 ConvOct lua require('conv.init').parseMode('oct', <f-args>)")
    vim.cmd("command! -nargs=1 ConvStr lua require('conv.init').parseMode('str', <f-args>)")
  }

return {
  parseMode = parseMode,
  setup = setup
}
