local ft_mapper = require('ft-mapper')
vim.keymap.set({ 'n', 'v', 'o' }, '<Right>', function()
  if ft_mapper.is_ft_repeatable() then
    return '<Plug>(forward_repeat)'
  else
    return '<Right>'
  end
end, { expr = true })
