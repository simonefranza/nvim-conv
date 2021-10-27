local utils = require('conv.utils')

local HL_NAME = 'nvimConvColor'
local NS_NAME = 'nvimConv'

local TYPE_DISTANCE = 'distance'
local TYPE_WEIGHT = 'weight'
local TYPE_DTR = 'dataTransferRate'
local TYPE_UNKNOWN = 'unknown'

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

local function getPrecision ()
  return vim.fn.exists('g:conv_precision') ~= 0 and vim.api.nvim_get_var('conv_precision') or 2
end

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
  local precision = getPrecision()
  print(string.format("%s = %." .. precision .. "f°C = %." .. precision .. "f°F",
    initPar, param, param*1.8 + 32))
end

local function convertToCelsius(param)
  -- This function converts a temperature in Farenheit in any (2, 8, 10, 16) base
  -- to Celsius and prints it on screen
  -- @param: string of the number
  local initPar = param
  param = utils.checkOctal(param)
  local precision = getPrecision()
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
  local precision = getPrecision()
  print(string.format('%.' .. precision .. 'f %s = %.' .. precision .. 'f %s', value, fromUnit,
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
  local precision = getPrecision()
  print(string.format('%.' ..precision .. 'f %s = %.' .. precision .. 'f %s', value, utils.prettifyDTRUnit(fromUnit),
    value*conversionMap[fromUnit]/conversionMap[toUnit], utils.prettifyDTRUnit(toUnit)))
end

local function inferFormat(color)
  -- This function tries to infer the format of the color, if it is not possible
  -- it defaults to rgb, if the string has some errors an error is thrown
  -- @color: string with only numbers (or hex)
  -- Output: format of the color {hexHalf, hex, rgb, hsl}

  -- Detect Hex
  -- format 9eb -> #99eebb
  if not color:find(' ') and color:len() == 3 then
    return 'hexHalf'
  -- format ababab -> #ababab
  elseif not color:find(' ') and color:len() == 6 then
    return 'hex'
  elseif color:len() >= 5 and color:len() <= 8 and color:find('[a-f]') then
    return 'hex'
  elseif color:find('[a-f]') then
    assert(false, '\nYou are probably trying to use a hex color,\n' ..
      'but some value is wrong. Try adding a "#" in front')
  elseif not color:find(' ') then
    assert(false, 'Failed type detection')
  -- Detect Rgb or Hsl
  else
    local colors = {}
    local len = 0
    for i in color:gmatch('[0-9]+') do
      assert(tonumber(i) >= 0, 'Detected negative value')
      table.insert(colors, tonumber(i))
      len = len + 1
    end
    assert(len == 3, 'Did you input more than tree values?')
    -- If first color value is > 255 then it can only be hsl
    if colors[1] > 255 and colors[1] <= 360 and colors[2] <= 100 and colors[3] <= 100 then
      return 'hsl'
    -- If second or third value are > 100 than it can only be rgb
    elseif ((colors[2] > 100 and colors[2] <= 255) or (colors[3] > 100 and colors[3] <= 255)) and
      colors[1] <= 255 then
        return 'rgb'
    end
  end
  vim.api.nvim_echo({{'The format of the color, cannot be inferred, so rgb is assumed. Add "#" (hex) or "hsl" in front if you whish to use another format.',
    "WarningMsg"}}, false, {})
  return 'rgb'
end

local function extractColors(colorStr, formatType, matchingString, valueBase, upperLimit, errorString)
  -- This function saves the values of the color in a table
  -- @colorStr: string with only numbers (or hex)
  -- @formatType: format of the color
  -- @matchingString: string used to match the values
  -- @valueBase: base of value (decimal or hex)
  -- @upperLimit: maximum that value may assume
  -- @errorString: error message to be displayed if upperLimit is exceeded
  -- Output: tables with 3 values
  local colors = {}
  local len = 0
  for i in colorStr:gmatch(matchingString) do
    local value = tonumber(i, valueBase)
    assert(value >= 0 and value <= upperLimit,
      string.format('Invalid ' .. formatType .. ' format: ' .. errorString, value))
    table.insert(colors, value)
    len = len + 1
  end
  return colors, len
end

local function parseColors(color, formatType)
  -- This function saves the values of the color in a table, after choosing the correct format
  -- @color: string with only numbers (or hex)
  -- @formatType: format of the color
  -- Output: tables with 3 values
  local colors = {}
  local len = 0
  if formatType == 'hexHalf' then
    assert(color:len() == 3,'Invalid short hex format: invalid length')
    assert(not color:find('[^0-9|^a-f]'), 'Invalid short hex format: invalid characters.')
    colors, len = extractColors(color, 'short hex', '[0-9|a-f]', 16,  0xF, 'value %02X not in [0x0, 0xF]')
    for idx=1,3,1 do
      colors[idx] = colors[idx] + 16*colors[idx]
    end
  elseif formatType == 'hex' and not color:find(' ') then
    assert(color:len() == 6,'Invalid hex format: invalid length')
    assert(not color:find('[^0-9|^a-f]'), 'Invalid hex format: invalid characters.')
    colors, len = extractColors(color, 'hex', '[0-9|a-f][0-9|a-f]', 16,  0xFF, 'value %02X not in [0x00, 0xFF]')
  elseif formatType == 'hex' then
    assert(not color:find('[^0-9|^a-f|^%s]'), 'Invalid hex format: invalid characters.')
    colors, len = extractColors(color, 'hex', '[0-9|a-f]+', 16,  0xFF, 'value %02X not in [0x00, 0xFF]')
  elseif formatType == 'rgb' then
    assert(not color:find('[^0-9|^%s]'), 'Invalid rgb format: invalid characters.')
    colors, len = extractColors(color, 'rgb', '[0-9]+', 10,  255, 'value %d not in [0, 255]')
  elseif formatType == 'hsl' then
    assert(not color:find('[^0-9|^%s|^%%|^%.]'), 'Invalid hsl format: invalid characters.')
    color = color:gsub('%%', ' ')
    colors, len = extractColors(color, 'hsl', '[0-9|%.]+', 10,  360, 'values too big.')
    local limits = {360, 100, 100}
    local labels = {'hue', 'saturation', 'lightness'}
    for idx=1,3,1 do
      assert(colors[idx] >= 0 and colors[idx] <= limits[idx],
        string.format('Invalid hsl format: %s %d not in [0, %d]', labels[idx], colors[idx], limits[idx]))
    end
  end
  assert(len == 3, 'Invalid color: exactly 3 values have to be provided.')
  return colors
end


local function convertColor(param)
  -- This function takes a color (in hex, rgb or hsl format) and prints out the
  -- other two versions
  -- @param: user string

  -- Remove parentheses, commas and trim leading/trailing whitespaces, change to lowercase
  local input = param:gsub('[,|%(|%)]', ' '):gsub("^%s*(.-)%s*$", "%1"):gsub('%s+', ' '):lower()
  local inferred = false
  local formatType = ''
  if input:find('rgb') then
    formatType = 'rgb'
    input = input:gsub('rgb', ''):gsub("^%s*(.-)%s*$", "%1"):gsub('%s+', ' ')
  elseif input:find('hsl') or input:find('%%') then
    formatType = 'hsl'
    input = input:gsub('hsl', ''):gsub("^%s*(.-)%s*$", "%1"):gsub('%s+', ' ')
  elseif input:find('#') then
    input = input:gsub('#', ''):gsub("^%s*(.-)%s*$", "%1"):gsub('%s+', ' ')
    if input:len() == 3 then
      formatType = 'hexHalf'
    else
      formatType = 'hex'
    end
  else
    formatType = inferFormat(input)
    inferred = true
  end
  local colors = parseColors(input, formatType)
  if formatType == 'hsl' then
    colors = utils.convertHsl2Rgb(colors)
  end
  local hexColor = string.format('#%02X%02X%02X', colors[1], colors[2], colors[3])
  local rgbColor = string.format('rgb(%d, %d, %d)', colors[1], colors[2], colors[3])
  local hslColor = utils.convertRgb2Hsl(colors)
  local outputStr = param
  if inferred then
    outputStr = outputStr .. ' (inferred ' .. formatType:sub(1,3) .. ')'
  end
  outputStr = outputStr .. ' = '
  if utils.startsWith(formatType, 'hex') then
    outputStr = outputStr .. rgbColor .. ' = ' .. hslColor
  elseif formatType == 'rgb' then
    outputStr = outputStr .. hexColor .. ' = ' .. hslColor
  else
    outputStr = outputStr .. hexColor .. ' = ' .. rgbColor
  end
  local bufHandle = vim.api.nvim_create_buf(false, true)
  --local winHandle = vim.api.nvim_open_win(bufHandle, false,
  --{relative='editor', row=30, col=40, width=2, height=1, focusable=false,
  --  style='minimal', border='none'})
    vim.api.nvim_buf_set_lines(bufHandle, 0, 1, false, {'  '})
    --vim.api.nvim_buf_add_highlight(bufHandle, -1, 'ErrorMsg', 0, 0, 2)
    local ns_id = vim.api.nvim_get_namespaces()[NS_NAME]
    vim.api.nvim__set_hl_ns(ns_id)
    vim.api.nvim_set_hl(ns_id, HL_NAME, {background=hexColor})
    vim.api.nvim_echo({{outputStr .. ' ', ''}, {'  ', HL_NAME}}, false, {})
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
              color = convertColor,
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
  vim.api.nvim_create_namespace(NS_NAME)
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
    command! -nargs=+ ConvColor lua require('conv.init').parseMode('color', <q-args>)
    command! -nargs=1 ConvSetPrecision lua require('conv.init').setPrecision(<f-args>)
  ]])
end

return {
  parseMode = parseMode,
  setPrecision = setPrecision,
  setup = setup
}
