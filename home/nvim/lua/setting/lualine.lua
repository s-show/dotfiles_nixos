require('lualine').setup({
  options = {
    icons_enabled = true,
    theme = 'papercolor_dark',
    component_separators = { left = '', right = '|' },
    section_separators = { left = '', right = '' },
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    globalstatus = false,
    refresh = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
    },
    tabline = {},
    winbar = {},
    inactive_winbar = {},
    extensions = {},
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch', 'diff', 'diagnostics' },
    lualine_c = { { 'filename', path = 4 } },
    lualine_x = { 'encoding', { 'fileformat', icons_enabled = true, symbols = { unix = 'LF', dow = 'CRLF', mac = 'CR' } }, 'filetype' },
    -- lualine_y = { 'progress' },
    lualine_y = {},
    lualine_z = { 'location' }
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = { 'branch', 'diff', 'diagnostics' },
    lualine_c = { { 'filename', path = 4 } },
    lualine_x = {},
    -- lualine_y = { 'progress' },
    lualine_y = {},
    lualine_z = {}
  },
})
