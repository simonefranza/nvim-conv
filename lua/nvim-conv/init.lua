local function startsWith(myString, substring)
  return string.sub(myString, 1, string.len(substring)) == substring
end

local function computeTwosComplement(binary)
  local len = string.len(binary)
  for cnt=len+1,2^(len+1),1 do
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
  local numberPar = vim.fn.eval(param)
  local isNegative = false
  if string.sub(numberPar,1,1) == '-' then
    isNegative = true
    numberPar = string.sub(numberPar, 2, string.len(numberPar))
  end

  local number = tonumber(numberPar) 
  if startsWith(numberPar, '0') and not startsWith(numberPar, '0x') and 
    not startsWith(numberPar, '0b') then
      number = tonumber(numberPar, 8)
  end
  local numBits = math.floor(math.log(number)/math.log(2))
  local outputStr = ""
  for cnt=0,numBits,1 do
    outputStr = bit.rshift(bit.band(number, bit.lshift(1, cnt)), cnt) .. outputStr
  end
  if isNegative then
    outputStr = computeTwosComplement(outputStr)
    numberPar = '-' .. numberPar
  end
  print(string.format('%s = 0b%s', numberPar, outputStr))
end

local function convertToDecimal(param)
  local initPar = param
  param = vim.fn.eval(param)
  if startsWith(param, '0') and not startsWith(param, '0x') and 
    not startsWith(param, '0b') then
      param = tonumber(param, 8)
  end
  print(string.format("%s = %d", vim.fn.eval(initPar), param))
end

local function convertToHex(param)
  local initPar = param
  param = vim.fn.eval(param)
  if startsWith(param, '0') and not startsWith(param, '0x') and 
    not startsWith(param, '0b') then
      param = tonumber(param, 8)
  end
  print(string.format("%s = 0x%X", vim.fn.eval(initPar), param))
end

local function convertToOct(param)
  local initPar = param
  param = vim.fn.eval(param)
  if startsWith(param, '0') and not startsWith(param, '0x') and 
    not startsWith(param, '0b') then
      param = tonumber(param, 8)
  end
  print(string.format("%s = 0%o", vim.fn.eval(initPar), param))
end

local function convertToStr(param)
  local bytes = vim.fn.eval(param)
  local strRes = ""
  for idx=1,string.len(bytes)-1,2 do
    strRes = strRes .. string.char(tonumber(string.sub(bytes, idx, idx + 1), 16))
  end
  print(strRes)
end


local function parseMode(mode, param)
  local dict = {
                dec = convertToDecimal, 
                hex = convertToHex,
                bin = convertToBin,
                oct = convertToOct,
                str = convertToStr
              }
  dict[vim.fn.eval(mode)](param)
end

return {
  parseMode = parseMode
}
