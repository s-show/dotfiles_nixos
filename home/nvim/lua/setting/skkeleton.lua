--skkeleton
vim.keymap.set({ 'i', 'c', 't' }, '<C-j>', '<plug>(skkeleton-enable)', {})
vim.keymap.set({ 'i', 'c', 't' }, '<C-l>', '<plug>(skkeleton-disable)', {})
vim.fn['skkeleton#config']({
  globalDictionaries = {
    vim.fn["expand"]('~/.config/nvim/skk_dict/SKK-JISYO.L'),
    vim.fn["expand"]('~/.config/nvim/skk_dict/SKK-JISYO.geo'),
    vim.fn["expand"]('~/.config/nvim/skk_dict/SKK-JISYO.jinmei'),
    vim.fn["expand"]('~/.config/nvim/skk_dict/SKK-JISYO.law'),
  },
  eggLikeNewline = true,
  keepState = true,
  showCandidatesCount = 2,
  registerConvertResult = true,
  markerHenkan = '',
  markerHenkanSelect = ''
})

vim.g.denops_server_deno_args = { '--unstable-kv' }
vim.fn['skkeleton#config']({
  databasePath = vim.fn["expand"]('~/.config/nvim/skk_dict/')
})

vim.fn['skkeleton#register_kanatable']('rom', {
  ['jk']  = 'escape',
  -- 丸数字
  -- ref: https://ja.wikipedia.org/wiki/丸数字
  ['z0']  = { '⓪', '' },
  ['z1']  = { '①', '' },
  ['z2']  = { '②', '' },
  ['z3']  = { '③', '' },
  ['z4']  = { '④', '' },
  ['z5']  = { '⑤', '' },
  ['z6']  = { '⑥', '' },
  ['z7']  = { '⑦', '' },
  ['z8']  = { '⑧', '' },
  ['z9']  = { '⑨', '' },
  ['z10'] = { '⑩', '' },
})

vim.cmd('source ~/.config/nvim/lua/setting/skkeleton-henkan-highlight.vim')
