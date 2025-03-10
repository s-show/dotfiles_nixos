--skkeleton
vim.api.nvim_set_keymap('i', '<C-j>', [[<Plug>(skkeleton-enable)]], { noremap = true })
vim.api.nvim_set_keymap('i', '<C-l>', [[<Plug>(skkeleton-disable)]], { noremap = true })
vim.api.nvim_set_keymap('c', '<C-j>', [[<Plug>(skkeleton-enable)]], { noremap = true })
vim.api.nvim_set_keymap('c', '<C-l>', [[<Plug>(skkeleton-disable)]], { noremap = true })
vim.fn['skkeleton#config']({
  globalDictionaries = {
    -- vim.fn["expand"]('~/AppData/Local/nvim/skk_dict/SKK-JISYO.L')
    -- ->C:\Users\shouhei shimizu\AppData\Local\nvim\skk_dict\SKK-JISYO.L
    vim.fn["expand"]('~/.config/nvim/skk_dict/SKK-JISYO.L'),
    vim.fn["expand"]('~/.config/nvim/skk_dict/SKK-JISYO.geo'),
    vim.fn["expand"]('~/.config/nvim/skk_dict/SKK-JISYO.jinmei'),
    vim.fn["expand"]('~/.config/nvim/skk_dict/SKK-JISYO.law'),
  },
  databasePath = vim.fn["expand"]('~/AppData/Local/nvim/skk_dict'),
  eggLikeNewline = true,
  keepState = true,
  showCandidatesCount = 2,
  registerConvertResult = true
})
-- vim.fn['skkeleton#register_keymap']('input', '/', 'abbrev')

vim.fn['skkeleton#register_kanatable']('rom', {
  ['jj'] = 'escape',
  -- ['kz'] = { 'かん', '' },
  -- ['kx'] = { 'きん', '' },
  -- ['kc'] = { 'くん', '' },
  -- ['kv'] = { 'けん', '' },
  -- ['kb'] = { 'こん', '' },
  -- ['sz'] = { 'さん', '' },
  -- ['sx'] = { 'しん', '' },
  -- ['sc'] = { 'すん', '' },
  -- ['sv'] = { 'せん', '' },
  -- ['sb'] = { 'そん', '' },
  -- ['tz'] = { 'たん', '' },
  -- ['tx'] = { 'ちん', '' },
  -- ['tc'] = { 'つん', '' },
  -- ['tv'] = { 'てん', '' },
  -- ['tb'] = { 'とん', '' },
  -- ['nz'] = { 'なん', '' },
  -- ['nx'] = { 'にん', '' },
  -- ['nc'] = { 'ぬん', '' },
  -- ['nv'] = { 'ねん', '' },
  -- ['nb'] = { 'のん', '' },
  -- ['hz'] = { 'はん', '' },
  -- ['hx'] = { 'ひん', '' },
  -- ['hc'] = { 'ふん', '' },
  -- ['hv'] = { 'へん', '' },
  -- ['hb'] = { 'ほん', '' },
  -- ['mz'] = { 'まん', '' },
  -- ['mx'] = { 'みん', '' },
  -- ['mc'] = { 'むん', '' },
  -- ['mv'] = { 'めん', '' },
  -- ['mb'] = { 'もん', '' },
  -- ['yz'] = { 'やん', '' },
  -- ['yc'] = { 'ゆん', '' },
  -- ['yb'] = { 'よん', '' },
  -- ['rz'] = { 'らん', '' },
  -- ['rx'] = { 'りん', '' },
  -- ['rc'] = { 'るん', '' },
  -- ['rv'] = { 'れん', '' },
  -- ['rb'] = { 'ろん', '' },
  -- ['wz'] = { 'わん', '' },
  -- ['wb'] = { 'をん', '' },
  -- ['gz'] = { 'がん', '' },
  -- ['gx'] = { 'ぎん', '' },
  -- ['gc'] = { 'ぐん', '' },
  -- ['gv'] = { 'げん', '' },
  -- ['gb'] = { 'ごん', '' },
  -- ['zz'] = { 'ざん', '' },
  -- ['zx'] = { 'じん', '' },
  -- ['zc'] = { 'ずん', '' },
  -- ['zv'] = { 'ぜん', '' },
  -- ['zb'] = { 'ぞん', '' },
  -- ['dz'] = { 'だん', '' },
  -- ['dx'] = { 'ぢん', '' },
  -- ['dc'] = { 'づん', '' },
  -- ['dv'] = { 'でん', '' },
  -- ['db'] = { 'どん', '' },
  -- ['bz'] = { 'ばん', '' },
  -- ['bx'] = { 'びん', '' },
  -- ['bc'] = { 'ぶん', '' },
  -- ['bv'] = { 'べん', '' },
  -- ['bb'] = { 'ぼん', '' },
  -- 丸数字
  -- ref: https://ja.wikipedia.org/wiki/丸数字
  ['z0'] = { '⓪', '' },
  ['z1'] = { '①', '' },
  ['z2'] = { '②', '' },
  ['z3'] = { '③', '' },
  ['z4'] = { '④', '' },
  ['z5'] = { '⑤', '' },
  ['z6'] = { '⑥', '' },
  ['z7'] = { '⑦', '' },
  ['z8'] = { '⑧', '' },
  ['z9'] = { '⑨', '' },
  ['z10'] = { '⑩', '' },
})

-- https://github.com/Shougo/ddc.vim/blob/abd90cb2f3acf557d6ea6b98dbe74bbc58c0c479/doc/ddc.txt#L1424-L1438 のコードを元に実装
local skkeleton = vim.api.nvim_create_augroup("skkeleton", { clear = true })
vim.api.nvim_create_autocmd(
  { 'User' },
  {
    group = skkeleton,
    pattern = 'skkeleton-enable-pre',
    callback = function()
      vim.b.prev_buffer_config = vim.fn["ddc#custom#get_buffer"]()
      vim.fn["ddc#custom#patch_buffer"]({
        sources = {
          'skkeleton',
        }
      })
    end
  }
)
vim.api.nvim_create_autocmd(
  { 'User' },
  {
    group = skkeleton,
    pattern = 'skkeleton-disable-pre',
    callback = function()
      vim.fn["ddc#custom#set_buffer"](vim.b.prev_buffer_config)
    end
  }
)
