if vim.o.buftype == "help" then
  if vim.o.columns >= 166 then
    vim.cmd("wincmd L | vertical resize 80")
  else
    local help_win_width = vim.o.columns / 2
    vim.cmd("wincmd L | vertical resize" .. tostring(help_win_width))
  end
end
