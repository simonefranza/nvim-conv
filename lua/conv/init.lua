local TYPE_DISTANCE = 'distance'
local TYPE_WEIGHT = 'weight'
local TYPE_DTR = 'dataTransferRate'
local TYPE_UNKNOWN = 'unknown'
local utils = require('conv.utils')

local correspondenceDistance = {
  ---- Metric
  kilometer='km', hectometer='hm', dekameter='dam', meter='m',
  decimeter='dm', centimeter='cm', millimeter='mm', micrometer='um',
  nanometer='nm',
  km='km', hm='hm', dam='dam', m='m',
  dm='dm', cm='cm', mm='mm', um='um',
  nm='nm',
  ----  Imperial
  nauticalmile='nmi', mile='mi', yard='yd', foot='ft', feet='ft', inche='inch',
  inch='inch',
  nmi='nmi', mi='mi', yd='yd', ft='ft',
}
local correspondenceWeight = {
  ---- Weight - Metric
  kilogram='kg', hectogram='hg', dekagram='dag', gram='g',
  decigram='dg', centigram='cg', milligram='mg', microgram='ug',
  nanogram='ng',
  kg='kg', hg='hg', dag='dag', g='g',
  dg='dg', cg='cg', mg='mg', ug='ug',
  ng='ng',
  ---- Weight - Imperial
  pound='lb', libra='lb', libre='lb', ounce='oz',
  lb='lb', oz='oz'
}
local correspondenceDTR = {
  ---- Bits
  bps='bps', kbps='kbps', mbps='mbps', gbps='gbps', tbps='tbps',
  bits='bps', kbits='kbps', mbits='mbps', gbits='gbps', tbits='tbps',
  ---- Bytes
  bs='bs', kbs='kbs', mbs='mbs', gbs='gbs', tbs='tbs'
}

local suitedFunctions = {
  distance = 'ConvMetricImperial',
  weight = 'ConvMetricImperial',
  dataTransferRate = 'ConvDataTransRate'
}

local defaultUnits = {
  distance = 'm',
  weight = 'kg',
  dataTransferRate = 'mbs'
}

local function convertToBin(param)
  -- This function converts a number from any (2, 8, 10, 16) base to binary and
  -- prints it on screen
  -- @param: string of the number
  local isNegative = false
  if string.sub(param,1,1) == '-' then
    isNegative = true
    param = string.sub(param, 2, string.len(param))
  end

  local number = tonumber(utils.checkOctal(param))
  local numBits = math.floor(math.log(number)/math.log(2))
  local outputStr = ""
  for cnt=0,numBits,1 do
    outputStr = bit.rshift(bit.band(number, bit.lshift(1, cnt)), cnt) .. outputStr
  end
  if isNegative then
    outputStr = utils.computeTwosComplement(outputStr)
    param = '-' .. param
  end
  print(string.format('%s = 0b%s', param, outputStr))
end


local function convertToHex(param)
  -- This function converts a number from any (2, 8, 10, 16) base to hex and
  -- prints it on screen
  -- @param: string of the number
  print(string.format("%s = 0x%X", param, utils.checkOctal(param)))
end

local function convertToOct(param)
-- This function converts a number from any (2, 8, 10, 16) base to octal and
-- prints it on screen
-- @param: string of the number
  print(string.format("%s = 0%o", param, utils.checkOctal(param)))
end

local function convertToStr(param)
  -- This function converts a sequence of bytes to the corresponding string and
  -- prints it on screen
  -- @param: string of bytes (whitespace separated)
  local strRes = ""
  local idx = 1
  while idx <= string.len(param) do
    while string.sub(param, idx, idx) == " " do
      idx = idx + 1
    end
    strRes = strRes .. string.char(tonumber(string.sub(param, idx, idx + 1), 16))
    idx = idx + 2
  end
  print(string.format("%s = %s", param, strRes))
end

local function convertToBytes(param)
  -- This function converts a string to the corresponding bytes sequence and
  -- prints it on screen
  -- @param: string (whitespace allowed)
  local strRes = ""
  for idx = 1, string.len(param), 1 do
    strRes = strRes .. string.format("%X", string.byte(param, idx))
  end
  print(string.format("%s = 0x%s", param, strRes))
end

local function convertToDecimal(param)
  -- This function converts a number from any (2, 8, 10, 16) base to decimal and
  -- prints it on screen
  -- @param: string of the number
  print(string.format("%s = %d", param, utils.checkOctal(param)))
end

local function convertToFarenheit(param)
  -- This function converts a temperature in Celsius in any (2, 8, 10, 16) base
  -- to Farenheit and prints it on screen
  -- @param: string of the number
  local initPar = param
  param = utils.checkOctal(param)
  local precision = vim.g.conv_precision
  print(string.format("%s = %." .. precision .. "f°C = %." .. precision .. "f°F",
    initPar, param, param*1.8 + 32))
end

local function convertToCelsius(param)
  -- This function converts a temperature in Farenheit in any (2, 8, 10, 16) base
  -- to Celsius and prints it on screen
  -- @param: string of the number
  local initPar = param
  param = utils.checkOctal(param)
  local precision = vim.g.conv_precision
  print(string.format("%s = %." .. precision .. "f°F = %." .. precision .. "f°C",
    initPar, param, (param-32)/1.8))
end

local function checkUnit(unit, correspondences)
  -- This function checks if the unit is valid and if not prints the most similar
  -- unit
  -- @unit: unit to check
  -- @correspondences: table with tables of valid units
  -- Output: the original inputted unit, the corresponding internal unit, type of unit
  if unit == nil then
    return nil, nil, TYPE_UNKNOWN
  end
  local modUnit = unit
  local dtrUnit = string.lower(unit)
  local len = string.len(unit)
  if string.sub(modUnit, len, len) == 's' then
    modUnit = string.sub(unit, 1, len-1)
  end
  if string.find(dtrUnit, '/') then
    dtrUnit = string.gsub(dtrUnit, '/', '')
  end

  if correspondenceDistance[modUnit] ~= nil then
    return unit, correspondenceDistance[modUnit], TYPE_DISTANCE
  elseif correspondenceWeight[modUnit] ~= nil then
    return unit, correspondenceWeight[modUnit], TYPE_WEIGHT
  elseif correspondenceDTR[dtrUnit] ~= nil then
    return unit, correspondenceDTR[dtrUnit], TYPE_DTR
  end

  if modUnit == "'" then
    return unit, 'ft', TYPE_DISTANCE
  elseif modUnit == '"' or modUnit == 'in' then
    return unit, 'inch', TYPE_DISTANCE
  end
  assert(false, string.format(
      '\n%s is not a valid unit. Did you mean %s?\n' ..
      'If the unit is valid and you would like it to be added to this plugin,\n' ..
      'please open an issue.',
      unit, utils.findClosestMatch(unit, correspondences)))
end

local function checkType(unit, myType, allowedTypes)
  -- This function checks if the type of unit is allowed for the conversion
  -- @unit: string of the unit, used only if the unit is not allowed
  -- @myType: type of unit to check
  -- @allowedTypes: table with the allowed types
  local isTypeOK = false
  for _,v in ipairs(allowedTypes) do
    if myType == v then
      isTypeOK = true
      break
    end
  end
  if isTypeOK then
    return
  end
  assert(isTypeOK, string.format('\nThis unit (%s) is not allowed with this command.\n' ..
    'Please try with :%s\n', unit, suitedFunctions[myType]))
end

local function parseUnits(param, allowedTypes, correspondences)
  -- This function takes a user string and extracts the value and the units used
  -- Then it checks if the conversion is allowed
  -- @param: user string
  -- @allowedTypes: table of allowed unit types
  -- @correspondences: table of tables with the possible correspondences
  -- Output: value, original unit, unit to convert to
  local it = string.gmatch(param, '[%g]+')
  local value = utils.checkOctal(it())
  local fromIn, fromUnit, fromType = checkUnit(it(), correspondences)
  assert(fromUnit ~= nil, '\nThe first unit is mandatory. Please provide one.')
  checkType(fromUnit, fromType, allowedTypes)
  local toIn, toUnit, toType = checkUnit(it(), correspondences)
  if toUnit == nil then
    toType = fromType
    toUnit = defaultUnits[toType]
    toIn = toUnit
  end
  checkType(toUnit, toType, allowedTypes)
  assert(fromType == toType, string.format(
      '\n%s (=%s type %s) is incompatible with %s (=%s type %s).\n' ..
      'Please choose compatible units.',
      fromIn, fromUnit, fromType, toIn, toUnit, toType))
  return value, fromUnit, toUnit
end

local function convertMetricImperial(param)
  -- This function performs conversions between metric and imperial units and prints
  -- it on screen
  -- @param: user string
  local value, fromUnit, toUnit = parseUnits(param, {TYPE_DISTANCE, TYPE_WEIGHT},
    {correspondenceDistance, correspondenceWeight})
  local conversionMap= {
    ---- Distance - Metric
    km=10^3, hm=10^2, dam=10, m=1, dm=10^-1, cm=10^-2, mm=10^-3, um=10^-6, nm=10^-9,
    ---- Distance - Imperial
    nmi=1852, mi=1609.344, yd=0.9144, ft=0.3048, inch=0.0254,
    ---- Weight - Metric
    kg=10^3, hg=10^2, dag=10, g=1, dg=10^-1, cg=10^-2, mg=10^-3, ug=10^-6, ng=10^-9,
    ---- Weight - Imperial
    lb=453.592, oz=28.3495,
  }
  local precision = vim.g.conv_precision
  print(string.format('%d %s = %.' .. precision .. 'f %s', value, fromUnit,
      value*conversionMap[fromUnit]/conversionMap[toUnit], toUnit))
end


local function convertDataTransferRate(param)
  -- This function performs conversions between data transfer rates and prints
  -- it on screen
  -- @param: user string
  local value, fromUnit, toUnit = parseUnits(param, {TYPE_DTR},
    {correspondenceDTR})
  local conversionMap= {
    ---- Bits
    bps=10^-6, kbps=10^-3, mbps=1, gbps=10^3, tbps=10^6,
    ---- Bytes
    bs=8*10^-6, kbs=8*10^-3, mbs=8, gbs=8*10^3, tbs=8*10^6
  }
  print(string.format('%d %s = %.' .. vim.g.conv_precision .. 'f %s', value, utils.prettifyDTRUnit(fromUnit),
    value*conversionMap[fromUnit]/conversionMap[toUnit], utils.prettifyDTRUnit(toUnit)))
end

local function parseMode(mode, param)
  -- This function dispatches the conversion to the correct functions
  -- @mode: string indicating the type of conversion
  -- @param: user string
  local dict = {
              dec = convertToDecimal,
              hex = convertToHex,
              bin = convertToBin,
              oct = convertToOct,
              str = convertToStr,
              bytes = convertToBytes,
              far = convertToFarenheit,
              cel = convertToCelsius,
              met = convertMetricImperial,
              dtr = convertDataTransferRate,
            }
  dict[mode](param)
end

local function setPrecision(value)
  -- This function set the precision for the output of float numbers
  -- @value: desired precision
  value = tonumber(value)
  assert(value and value >= 0, '\nThe precision has to be a number greater or equal to zero.')
  vim.g.conv_precision = value
end

local function setup()
  vim.g.conv_precision = 2
  vim.cmd([[
    command! -nargs=1 ConvBin lua require('conv.init').parseMode('bin', <f-args>)
    command! -nargs=1 ConvDec lua require('conv.init').parseMode('dec', <f-args>)
    command! -nargs=1 ConvHex lua require('conv.init').parseMode('hex', <f-args>)
    command! -nargs=1 ConvOct lua require('conv.init').parseMode('oct', <f-args>)
    command! -nargs=1 ConvFarenheit lua require('conv.init').parseMode('far', <f-args>)
    command! -nargs=1 ConvCelsius lua require('conv.init').parseMode('cel', <f-args>)
    command! -nargs=+ ConvStr lua require('conv.init').parseMode('str', <q-args>)
    command! -nargs=+ ConvBytes lua require('conv.init').parseMode('bytes', <q-args>)
    command! -nargs=+ ConvMetricImperial lua require('conv.init').parseMode('met', <q-args>)
    command! -nargs=+ ConvDataTransRate lua require('conv.init').parseMode('dtr', <q-args>)
    command! -nargs=1 ConvSetPrecision lua require('conv.init').setPrecision(<f-args>)
  ]])
end

return {
  parseMode = parseMode,
  setPrecision = setPrecision,
  setup = setup
}
