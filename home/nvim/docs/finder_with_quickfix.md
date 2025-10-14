# Neovimでファイル検索とQuickfixを統合したプレビュー機能の実装

## はじめに

Neovimでコーディングをしていると、ファイル検索や文字列検索の結果を素早く確認したいことがよくあります。標準のQuickfixリストは便利ですが、選択したアイテムの内容をリアルタイムでプレビューできれば、さらに効率的に作業できるのではないでしょうか。

本記事では、Neovimのquickfixリストに対してリアルタイムプレビュー機能を追加し、ファイル検索（fd/find）、ファジー検索、grep検索、バッファリストなど、様々な検索結果を統一的に扱えるモジュールの実装について解説します。

## モジュールの概要と目的

このquickfix_previewモジュールは、以下の機能を提供します：

1. **統一的な検索インターフェース**: fd/find、grep、ファジー検索、バッファリストなど、異なる検索方法の結果をquickfixリストで統一的に表示
2. **リアルタイムプレビュー**: quickfixリスト上でカーソルを移動すると、選択したファイルの内容をフローティングウィンドウで即座にプレビュー
3. **コンテキスト認識**: 検索方法に応じて最適なプレビュー内容を表示（ファイル検索なら先頭部分、grep検索なら該当行周辺）
4. **効率的な操作**: 垂直/水平分割での開き方、プレビューの表示/非表示切り替えなど、生産性を高めるキーマッピング

## アーキテクチャと主要コンポーネント

モジュールは以下の5つのファイルで構成されています：

```
util/quickfix_preview/
├── init.lua     # メインモジュール（外部インターフェース）
├── state.lua    # 状態管理
├── search.lua   # ファイル検索機能
├── qf.lua       # quickfixリスト操作
└── preview.lua  # プレビューウィンドウ管理
```

### 1. state.lua - 状態管理モジュール

```lua
local state = {
  preview_win = nil,        -- プレビューウィンドウのID
  preview_buf = nil,        -- プレビューバッファのID
  display_preview = false,  -- プレビュー表示フラグ
  closing_preview = false,  -- クローズ処理中フラグ
  source = 'grep'          -- 検索ソース（'grep', 'find', 'buffers'）
}
```

状態管理は単純なテーブルとアクセサ関数で実装されています。特に重要なのは`source`フィールドで、これによって検索方法に応じた適切なプレビュー表示を実現しています。

### 2. search.lua - ファイル検索機能

ファイル検索は、高速な`fd`コマンドと標準的な`find`コマンドの両方をサポートしています：

```lua
local function build_fd_command(exclude_dirs, search_file)
  local exclude_parts = {}
  for _, dir in ipairs(exclude_dirs) do
    table.insert(exclude_parts, "--exclude " .. vim.fn.shellescape(dir))
  end
  
  if util.is_blank_text(search_file) == false then
    return string.format(
      [[fd %s --type f --hidden %s . | awk '{ flag = ($0 ~ /(^|\/)\./ ? 0 : 1); print flag "|" $0 }' | sort -t'|' -k1,1 -k2,2 | cut -d'|' -f2-]],
      vim.fn.shellescape(search_file),
      table.concat(exclude_parts, " ")
    )
  else
    -- 全ファイルを取得
  end
end
```

注目すべき点：
- `.git`、`node_modules`などの一般的なディレクトリは自動的に除外
- 隠しファイルは結果に含まれるが、ソート時に優先順位を下げる
- AWKを使用してドットファイルにフラグを付け、非ドットファイルを優先的に表示

### 3. qf.lua - Quickfixリスト操作

このモジュールはquickfixリストへのデータ投入と、アイテムの操作を担当します：

```lua
function M.populate_files(file_list)
  local qflist = {}
  for _, file in ipairs(file_list) do
    table.insert(qflist, {
      filename = file,
      lnum = 1,
      text = file
    })
  end
  vim.fn.setqflist(qflist)
  vim.cmd('copen')
end
```

バッファリストの実装は特に興味深く、最近使用した順でソートしています：

```lua
function M.populate_buffers()
  local bufinfos = vim.fn.getbufinfo({ buflisted = 1 })
  
  -- lastused でソート（最近使用したものが上に）
  table.sort(bufinfos, function(a, b)
    return (a.lastused or 0) > (b.lastused or 0)
  end)
  
  -- 変更されているバッファには [+] を追加
  if bufinfo.changed == 1 then
    text = text .. ' [+]'
  end
end
```

### 4. preview.lua - プレビューウィンドウ管理

プレビュー機能の中核部分です。フローティングウィンドウを使用してファイル内容を表示します：

```lua
function M.show(opts)
  local item = qflist[current_line]
  local filename = (item.bufnr and vim.fn.bufname(item.bufnr)) or item.filename or ''
  
  -- 検索ソースに応じてプレビュー内容を調整
  if state.is_from_find() then
    -- fd/find の場合は最初の7行
    result = vim.fn.readfile(filename, '', 7)
  else
    -- grep等の場合は該当行の前後を含めて読み込み
    local from_line = math.max(1, lnum - 3)
    local to_line = lnum + 3
    -- 該当行を中心に前後3行を表示
  end
  
  -- フローティングウィンドウの設定
  local win_opts = {
    relative = 'win',
    width = math.floor(win_width * 0.5),
    height = math.min(20, math.floor(win_height * 0.7)),
    col = win_width - preview_width - 2,  -- 右側に配置
    row = 1,
    style = 'minimal',
    border = 'rounded',
    title = ' Preview: ' .. vim.fn.fnamemodify(filename, ':t') .. ' ',
  }
end
```

### 5. init.lua - メインモジュール

全体の統合と外部インターフェースを提供します。自動コマンドによるイベント処理が特徴的です：

```lua
-- Quickfixウィンドウでカーソルが動いたときにプレビューを更新
vim.api.nvim_create_autocmd({ 'CursorMoved' }, {
  group = augroup,
  pattern = '*',
  callback = function()
    if vim.bo.buftype == 'quickfix' and state.get().display_preview then
      preview.show({ debug_mode = debug_mode })
    end
  end
})
```

## ファジー検索の実装

特筆すべき機能として、独自のファジー検索アルゴリズムを実装しています。`fuzzy_rank.lua`では、以下の優先順位でマッチングを行います：

1. **完全一致**: クエリとファイル名が完全に一致
2. **前方一致**: ファイル名またはパスセグメントの先頭から一致
3. **部分文字列**: ファイル名の任意の位置で連続して一致
4. **サブシーケンス**: 文字が順番通りに出現（連続でなくても可）

同一カテゴリー内では、正規化レーベンシュタイン距離でソートすることで、より自然な検索結果を実現しています。

## 設計上の工夫と最適化

### 1. リソース管理

プレビューウィンドウとバッファの適切な管理により、メモリリークを防いでいます：

```lua
-- ウィンドウを閉じる前に、バッファの参照を一時保存
local buf_to_delete = s.preview_buf

-- ウィンドウを閉じる
pcall(vim.api.nvim_win_close, s.preview_win, true)

-- バッファが他のウィンドウで使われていない場合のみ削除
if buf_to_delete and vim.api.nvim_buf_is_valid(buf_to_delete) then
  local wins = vim.fn.win_findbuf(buf_to_delete)
  if #wins == 0 then
    pcall(vim.api.nvim_buf_delete, buf_to_delete, { force = true })
  end
end
```

### 2. パフォーマンスの最適化

- 大きなファイルでは先頭部分のみを読み込む（7行）
- バイナリファイルの検出と適切なエラーハンドリング
- ファイル存在チェックによる無駄な処理の回避

### 3. ユーザビリティの向上

検索結果に対する様々な操作をサポート：

- `p`: プレビューの表示/非表示切り替え
- `<C-o>`: アイテムを開いてquickfixを閉じる
- `<C-v>`: 垂直分割で開く
- `<C-s>`: 水平分割で開く
- `q`: quickfixウィンドウを閉じる

## 使用例

```vim
" ファイル名でファイル検索
:Findqf config

" ファジー検索
:Fzfqf nvim init

" grep検索（自動でプレビュー表示）
:Grep TODO

" バッファリストを表示
:Bufqf

" キーマッピングでの使用
<leader>d    " ファイル検索
<leader>z    " ファジー検索
<leader>gr   " grep検索
<leader>qb   " バッファリスト
```

## まとめ

このquickfix_previewモジュールは、Neovimの標準機能であるquickfixリストを拡張し、様々な検索方法を統一的に扱えるようにしました。特に以下の点で開発効率の向上が期待できます：

1. **即座のコンテキスト確認**: ファイルを開かずに内容を確認できる
2. **統一的な操作性**: 異なる検索方法でも同じインターフェースで操作
3. **柔軟な検索オプション**: 完全一致からファジー検索まで幅広くサポート
4. **効率的なナビゲーション**: 分割ウィンドウでの開き方など、ワークフローに応じた操作

モジュール設計においては、各機能を独立したファイルに分離することで、保守性と拡張性を確保しました。今後は、プレビュー内容の構文ハイライトや、検索履歴機能の追加などの拡張も検討できるでしょう。

Neovimのカスタマイズ性を活かし、自分のワークフローに最適化されたツールを作ることで、日々のコーディングがより快適になることを願っています。