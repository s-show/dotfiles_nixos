-- Claude-code バッファ用の設定
local M = {}

-- 元のバッファIDを保存する変数
local original_buf_id = nil
local original_win_id = nil

-- バッファ名に claude-code- が含まれるかチェック
local function is_claude_code_buffer()
  local bufname = vim.api.nvim_buf_get_name(0)
  return string.find(bufname, "claude%-code%-") ~= nil
end

-- 新しいウィンドウを作成する関数
local function create_bottom_window()
  -- 現在のバッファとウィンドウIDを保存
  original_buf_id = vim.api.nvim_get_current_buf()
  original_win_id = vim.api.nvim_get_current_win()

  -- 現在のウィンドウの高さを取得
  local win_height = vim.api.nvim_win_get_height(0)

  -- 下側3分の1の高さを計算
  local new_height = math.floor(win_height / 3)

  -- 新しいウィンドウを下に作成
  vim.cmd('belowright ' .. new_height .. 'split')

  -- 新しいバッファを作成
  vim.cmd('enew')

  -- バッファの設定
  vim.bo.buftype = 'nofile'
  vim.bo.bufhidden = 'wipe'
  vim.bo.swapfile = false

  -- 200ms 待機してからインサートモードに入る
  vim.defer_fn(function()
    vim.cmd('startinsert')
  end, 200)
end

-- ウィンドウの内容をヤンクして閉じる関数
local function yank_and_close()
  -- 現在のバッファの全内容を取得
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local content = table.concat(lines, '\n')

  -- 無名レジスタにヤンク
  vim.fn.setreg('"', content)

  -- 現在のウィンドウを閉じる
  vim.cmd('close')

  -- 元のclaude-codeバッファにフォーカスを戻す
  if original_win_id and vim.api.nvim_win_is_valid(original_win_id) then
    vim.api.nvim_set_current_win(original_win_id)

    -- 200ms 待機してからノーマルモードに戻る
    vim.defer_fn(function()
      vim.cmd('stopinsert')

      -- 100ms 待機してから p キーを送信
      vim.defer_fn(function()
        vim.api.nvim_feedkeys('p', 'n', false)

        -- さらに 100ms 待機してから i キーを送信
        vim.defer_fn(function()
          vim.api.nvim_feedkeys('i', 'n', false)
        end, 100)
      end, 100)
    end, 200)
  end

  -- 変数をリセット
  original_buf_id = nil
  original_win_id = nil
end

-- キーマッピングの設定
function M.setup()
  -- claude-code- バッファでのみ有効なキーマッピング
  vim.api.nvim_create_autocmd({ "BufEnter", "BufNew" }, {
    pattern = "*",
    callback = function()
      if is_claude_code_buffer() then
        -- <leader>gi で新しいウィンドウを作成
        vim.api.nvim_buf_set_keymap(0, 'n', '<leader>gi', '', {
          noremap = true,
          silent = true,
          callback = create_bottom_window
        })
        vim.api.nvim_buf_set_keymap(0, 't', '<C-g>i', '', {
          noremap = true,
          silent = true,
          callback = create_bottom_window
        })
      end
    end
  })

  -- インサートモードでの <C-g>x キーマッピング（グローバル）
  vim.keymap.set('i', '<C-g>x', function()
    -- 元のバッファが設定されている場合のみ実行
    if original_buf_id then
      yank_and_close()
    end
  end, {
    silent = true
  })
end

-- 設定を実行
M.setup()

return M
