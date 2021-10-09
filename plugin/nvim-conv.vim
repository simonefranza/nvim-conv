fun! NvimConv(mode, param)
  lua for k in pairs(package.loaded) do if k:match("^nvim%-conv") then package.loaded[k] = nil end end
  lua require('nvim-conv').parseMode('a:mode', 'a:param')
endfun

command -nargs=1 ConvBin :call NvimConv('bin', <f-args>)
command -nargs=1 ConvDec :call NvimConv('dec', <f-args>)
command -nargs=1 ConvHex :call NvimConv('hex', <f-args>)
command -nargs=1 ConvOct :call NvimConv('oct', <f-args>)
command -nargs=1 ConvStr :call NvimConv('str', <f-args>)

augroup NvimConv()
  autocmd!
augroup END
