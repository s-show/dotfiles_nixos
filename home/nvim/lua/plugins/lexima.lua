return {
  "cohama/lexima.vim",
  -- インサートモードとコマンドラインに入った時に有効化することで
  -- 起動時の読み込み時間を短縮している。
  event = {
    "InsertEnter", "CmdlineEnter"
  },
  config = function()
    -- pum.vim の <CR> と衝突させないためにデフォルトルールを無効化
    vim.g.lexima_no_default_rules = 1
    vim.g.lexima_map_escape = "<Esc>"
    vim.g.lexima_enable_basic_rules = 1
    vim.g.lexima_enable_newline_rules = 1
    vim.g.lexima_enable_space_rules = 1
    vim.g.lexima_enable_endwise_rules = 1
    vim.g.lexima_accept_pum_with_enter = 0
    vim.g.lexima_ctrlh_as_backspace = 0
    vim.g.lexima_disable_on_nofile = 0
    vim.g.lexima_disable_abbrev_trigger = 0
    vim.fn['lexima#set_default_rules']()
    vim.fn["lexima#add_rule"]({
      char = '<',
      input_after = '>',
    })
    vim.fn['lexima#add_rule']({
      char = '>',
      at = [[\%#>]],
      leave =  1,
    })
    vim.fn['lexima#add_rule']({
      char = '<BS>',
      at = [[<\%#>]],
      delete =  1,
    })
  end
}
