local function startsWith(string, substring)
  return string.sub(string, 1, string.len(substring)) == substring
end

local function convertToBin(param)
  local numberPar = vim.fn.eval(param)
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
  print(string.format('%s = 0b%s', numberPar, outputStr))
end

local function convertToDecimal(param)
  print(string.format("%s = %d", vim.fn.eval(param), vim.fn.eval(param)))
end

local function convertToHex(param)
  print(string.format("%s = 0x%X", vim.fn.eval(param), vim.fn.eval(param)))
end

local function convertToOct(param)
  print(string.format("%s = 0%o", vim.fn.eval(param), vim.fn.eval(param)))
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
