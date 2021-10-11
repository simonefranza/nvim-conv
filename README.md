# nvim-conv

<div align='center'>
    [![GitHub Stars](https://img.shields.io/github/stars/simonefranza/nvim-conv?style=social)](https://github.com/simonefranza/nvim-conv/stargazers/)
    [![Last Commit](https://img.shields.io/github/last-commit/simonefranza/nvim-conv)](https://github.com/simonefranza/nvim-conv/pulse)
</div>

Conv is a simple converter that allows you to convert numbers and bytes.

## Installation

Install using your favorite plugin manager, for example for [Vim Plug](https://github.com/junegunn/vim-plug)
add the following to your .vimrc :

    Plug 'simonefranza/nvim-conv'

## Usage

The format to input numbers with different bases is the same as in the C language:

 - decimal: simply the number
 - hexadecimal: leading 0x
 - octal: leading 0
 - binary: leading 0b

This means that the number 45 has to be input as 0b101101 for binary, 0x2d (or 0x2D)
for hexadecimal and 055 for octal.

### Base conversion

Conversion from octal, hex and binary to decimal

    :ConvDec 0x2d
    0x2d = 45

Conversion from decimal, hex and binary to octal 

    :ConvOct 0x2d
    0x2d = 055

Conversion from decimal, octal and binary to hexadecimal 

    :ConvHex 45
    045 = 0x2D

Conversion from decimal, hexadecimal and octal to binary 

    :ConvBin 45
    45 = 0b101101

Also with negative numbers (the binary number is extended to the next multiple of
4)

    :ConvBin -3
    -3 = 0b1101

### Bytes to string

Converts a sequence of bytes to a string

    :ConvStr 6e76696d2d636f6e76
    6e76696d2d636f6e76 = nvim-conv

Even with spaces out bytes

    :ConvStr 6e 76 69 6d 2d 63 6f 6e 76
    6e 76 69 6d 2d 63 6f 6e 76 = nvim-conv

### String to bytes

Convert any string to a sequence of bytes

    :ConvBytes This plugin is amazing!
    This plugin is amazing! = 0x5468697320706C7567696E20697320616D617A696E6721


## Suggested mappings

Add these to your .vimrc for some fast conversion:

    nnoremap <Leader>cd :<C-u>ConvDec<Space>
    nnoremap <Leader>ch :<C-u>ConvHex<Space>
    nnoremap <Leader>co :<C-u>ConvOct<Space>
    nnoremap <Leader>cb :<C-u>ConvBin<Space>
    nnoremap <Leader>cs :<C-u>ConvStr<Space>
    nnoremap <Leader>ct :<C-u>ConvBytes<Space>

## TODOs

The following conversions are on the TODO list:

- miles to meters and viceversa
- Celsius to Farenheit and viceversa

## Add new conversions

If there is a conversion that you often use and you would like to
have it in neovim, open a new issue.

## License

Copyright (c) Simone Franza. Conv is distributed under MIT License.

<div align = "center">
    ![Lua](https://img.shields.io/badge/lua-%232C2D72.svg?style=for-the-badge&logo=lua&logoColor=white)
</div>
