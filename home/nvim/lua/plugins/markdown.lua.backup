return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    name = 'render-markdown',            -- Only needed if you have another plugin named markdown.nvim
    dependencies = {
      'nvim-treesitter/nvim-treesitter', -- Mandatory
      'nvim-tree/nvim-web-devicons',     -- Optional but recommended
    },
    opts = {
      heading = {
        position = 'overlay',
      },
      quote = {
        repeat_linebreak = true,
      },
      code = {
        border = 'thick'
      },
      win_options = {
        showbreak = { default = '', rendered = '  ' },
        breakindent = { default = false, rendered = true },
        breakindentopt = { default = '', rendered = '' },
      },
      html = {
        enabled = true,
        comment = {
          conceal = false,
        }
      }
    },
    ft = 'markdown',
  }
}
