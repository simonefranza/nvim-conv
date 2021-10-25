# nvim-conv

Conv is a simple converter that allows you to convert numbers and bytes.

## Installation

Install using your favorite plugin manager: 

* [NeoBundle](https://github.com/Shougo/neobundle.vim)
  ```vim
  NeoBundle 'simonefranza/nvim-conv'
  ```
* [packer.nvim](https://github.com/wbthomason/packer.nvim):
    ```lua
    use {'simonefranza/nvim-conv'}
    ```
* [vim-plug](https://github.com/junegunn/vim-plug):
  ```vim
  Plug 'simonefranza/nvim-conv'
  ```
* [Vundle](https://github.com/VundleVim/Vundle.vim)
  ```vim
  Plugin 'simonefranza/nvim-conv'
    ```

## Usage

The format to input numbers with different bases is the same as in the C language:

 - decimal: simply the number
 - hexadecimal: leading 0x
 - octal: leading 0
 - binary: leading 0b

This means that the number 45 has to be input as 0b101101 for binary, 0x2d (or 0x2D)
for hexadecimal and 055 for octal.

### Base conversion

Conversion from octal, hex and binary **to decimal**

    :ConvDec 0x2d
    0x2d = 45

Conversion from decimal, hex and binary **to octal**

    :ConvOct 0x2d
    0x2d = 055

Conversion from decimal, octal and binary **to hexadecimal**

    :ConvHex 45
    045 = 0x2D

Conversion from decimal, hexadecimal and octal **to binary**

    :ConvBin 45
    45 = 0b101101

Also with negative numbers (the binary number is extended to the next multiple of
4)

    :ConvBin -3
    -3 = 0b1101

### Bytes to string

Converts a sequence of bytes **to a string**

    :ConvStr 6e76696d2d636f6e76
    6e76696d2d636f6e76 = nvim-conv

Even with spaces out bytes

    :ConvStr 6e 76 69 6d 2d 63 6f 6e 76
    6e 76 69 6d 2d 63 6f 6e 76 = nvim-conv

### String to bytes

Convert any string **to a sequence of bytes**

    :ConvBytes This plugin is amazing!
    This plugin is amazing! = 0x5468697320706C7567696E20697320616D617A696E6721

### Celsius to Farenheit

The input may be in decimal, hex, binary or octal base:

    :ConvFarenheit 0b1100100
    0b1100100 = 100.00°C = 212.00°F 
    :ConvFarenheit 0xff
    0xff = 255.00°C = 491.00°F
    :ConvFarenheit -40
    -40 = -40.00°C = -40.00°F

### Farenheit to Celsius

The input may be in decimal, hex, binary or octal base:

    :ConvCelsius -135
    -135 = -135.00°F = -92.78°C
    :ConvCelsius 0xad2
    0xad2 = 2770.00°F = 1521.11°C
    0xff = 255.00°C = 491.00°F

### Data Transfer Rates

Use `:ConvDataTransRate <value> <fromUnit> <toUnit>` to perform a conversion
between data transfer rates.

The supported rates are:

    Bits per second
    Bps, Kbps, Mbps, Gbps, Tbps
    Bytes per second
    B/s, KB/s, MB/s, GB/s, TB/s

All the units are case insensitive. The units that specify bits per second
can also be defined as MBit/s (in the case of Mbps). The units that specify 
bytes per second can omit the '/', so MBs (or mbs) will be interpreted as MB/s.

    :ConvDataTransRate 10 MBit/s KB/s
    10 Mbps (MBit/s) = 1250.00 KB/s
    :ConvDataTransRate 10 mbs kbps
    10 MB/s = 80000.00 Kbps (KBit/s)

### Metric - Imperial units

Use `:ConvMetricImperial <value> <fromUnit> <toUnit>` to perform a conversion
from a metric unit to an imperial one.

The conversion can also be metric to metric (km to m for example) or imperial
to imperial (mile to feet). For a list of available units [see below](#length-units).

    :ConvMetricImperial 10 km ft 
    10 km = 32808.40 ft
    :ConvMetricImperial 1.52 meters cm
    1 m = 152.00 cm
    :ConvMetricImperial 1 foot inches
    1 ft = 12.00 inch

#### Unit names

The units can be entered in a shortened fashion as mentioned [below](#length-units)
or by their full name or even with the plural form.

Some examples of corresponding units:

    km, kilometer, kilometers = km
    mi, mile, miles = mi

Feet and inches can also be represented as ' and " respectively.

#### Length Units
Metric System

    km, hm, dam, m, dm, cm, mm, um (micrometer), nm

Imperial System

    nmi, mi, yd, ft (or '), in (or ")

#### Weight Units
Metric System
  
    kg, hg, dag, g, dg, cg, mg, ug, ng

Imperial System
  
    lb, oz

## Additional features

### Floating point precision

Per default the conversion always prints 2 decimal digits, if you wish 
to change it on the fly you can execute:
  
    :ConvSetPrecision 4

to get 4 decimal digits in the current session. This value is reset to 2 
when you restart vim.

If you wish to make a permanent change, add the following at the end of your .vimrc (or init.vim):

    let g:conv_precision = 4

Or this if you are using init.lua:

    vim.g.conv_precision = 4

## Suggested mappings

Add these to your init.vim (or .vimrc or init.lua) for some fast conversion:

    nnoremap <Leader>cd :<C-u>ConvDec<Space>
    nnoremap <Leader>ch :<C-u>ConvHex<Space>
    nnoremap <Leader>co :<C-u>ConvOct<Space>
    nnoremap <Leader>cb :<C-u>ConvBin<Space>
    nnoremap <Leader>cs :<C-u>ConvStr<Space>
    nnoremap <Leader>ct :<C-u>ConvBytes<Space>

## TODOs

If new conversions are wished for, they will be added here.

## Add new conversions

If there is a conversion that you often use and you would like to
have it in neovim, please open a new issue.

## License

Copyright (c) Simone Franza. Conv is distributed under MIT License.

<div align="center">
    <img src="https://img.shields.io/badge/NeoVim-%2357A143.svg?&style=for-the-badge&logo=neovim&logoColor=white" />
    <img src="https://img.shields.io/badge/lua-%232C2D72.svg?style=for-the-badge&logo=lua&logoColor=white" />
    </br>
    <a href="https://github.com/simonefranza/nvim-conv/stargazers/" alt="GitHub Stars">
        <img src="https://img.shields.io/github/stars/simonefranza/nvim-conv?style=social" />
    </a>
    <a href="https://github.com/simonefranza/nvim-conv/pulse" alt="Last Commit">
        <img src="https://img.shields.io/github/last-commit/simonefranza/nvim-conv" />
    </a>
</div>
