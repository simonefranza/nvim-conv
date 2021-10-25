for k in pairs(package.loaded) do
  if k:match("^nvim%-conv") or k:match("^conv") then
    package.loaded[k] = nil
  end
end

return require("conv.init").setup()
