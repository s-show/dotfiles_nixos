# 曖昧検索ランキングアルゴリズムの処理フロー

## 概要
このドキュメントでは、`fuzzy_rank.lua` で実装された曖昧検索ランキングアルゴリズムの処理の流れを詳しく説明します。

## 処理の全体フロー

```
入力: クエリ文字列、テキストリスト
↓
1. 前処理（大文字小文字の正規化）
↓
2. 各テキストに対してカテゴリー判定
↓
3. マッチしたテキストの類似度スコア計算
↓
4. 複数の基準でソート
↓
出力: ランキング済みテキストリスト
```

## 詳細な処理ステップ

### 1. 前処理フェーズ

```lua
-- デフォルトでは大文字小文字を無視
local q_cmp = case_sensitive and query or norm(query)
```

- `norm()` 関数で文字列を小文字に変換
- `case_sensitive` オプションが true の場合は元の文字列のまま比較

### 2. カテゴリー判定フェーズ

各テキストは以下の4つのカテゴリーのいずれかに分類されます：

#### カテゴリー1: 完全一致
```lua
if text_lc == query_lc then
    return 1, 1  -- カテゴリー1、位置1
end
```
- 例: クエリ "mini" → テキスト "mini"

#### カテゴリー2: 前方一致
```lua
-- 全体の前方一致
if string.sub(text_lc, 1, #query_lc) == query_lc then
    return 2, 1
end

-- パスセグメント単位の前方一致
for seg in iter_path_segments(text_lc) do
    if #seg > 0 and string.sub(seg, 1, #query_lc) == query_lc then
        local pos = string.find(text_lc, seg, 1, true) or 1
        return 2, pos
    end
end
```
- 例1: クエリ "mini" → テキスト "mini-ai.lua" （全体の前方一致）
- 例2: クエリ "mini" → テキスト "home/nvim/lua/plugins/mini-ai.lua" （セグメント "mini-ai.lua" の前方一致）

#### カテゴリー3: 部分文字列一致
```lua
local s, e = string.find(text_lc, query_lc, 1, true)
if s ~= nil then
    return 3, s  -- カテゴリー3、開始位置
end
```
- 例: クエリ "mini" → テキスト "home/nvim/lua/plugins/nvim_mini.lua" （位置24から一致）

#### カテゴリー4: サブシーケンス一致
```lua
if is_subsequence(query_lc, text_lc) then
    return 4, nil
end
```
- 例: クエリ "mini" → テキスト "home/nvim/lua/plugins/ddu-source-cmdline_history.lua"
  - 'm' (home), 'i' (nvim), 'n' (plugins), 'i' (cmdline) の順で出現

### 3. 類似度スコア計算フェーズ

#### レーベンシュタイン距離の計算
```lua
function levenshtein(a, b)
    -- 2行のDPテーブルを使用（メモリ効率化）
    local prev = {}  -- 前の行
    local curr = {}  -- 現在の行
    
    -- 動的計画法で編集距離を計算
    -- 削除、挿入、置換の最小コストを選択
end
```

##### メモリ効率化の工夫

通常のレーベンシュタイン距離の実装では、以下のような2次元配列を作成します：

```
|   | * | n | v | i | m | _ | m | i | n | i |
|---|---|---|---|---|---|---|---|---|---|---|
| * | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 |
| m | 1 |   |   |   |   |   |   |   |   |   |
| i | 2 |   |   |   |   |   |   |   |   |   |
| n | 3 |   |   |   |   |   |   |   |   |   |
| i | 4 |   |   |   |   |   |   |   |   |   |
```

しかし、この実装では `prev` と `curr` の2つの配列のみを使用することで、大幅にメモリを節約しています：

1. **2行のみの保持**：各セル `[i][j]` を計算する際に必要なのは：
   - `[i-1][j]`（削除）：`prev[j]` に保存
   - `[i][j-1]`（挿入）：`curr[j-1]` に保存
   - `[i-1][j-1]`（置換）：`prev[j-1]` に保存

2. **配列の再利用**：115行目の `prev, curr = curr, prev` で配列の参照を入れ替えることで、新しい配列を作成せずに済む

3. **短い文字列を優先**：88-91行目で短い文字列を `a` にすることで、配列のサイズを最小限に抑える

結果として、空間複雑度が `O(m×n)` から `O(min(m,n))` に削減され、大量のテキストをランキングする際のメモリ使用量が大幅に改善されています。

#### 正規化距離の計算
```lua
function normalized_distance(a, b)
    local d = levenshtein(a, b)
    local m = (la > lb) and la or lb  -- 長い方の文字列長
    return d / m  -- 0.0〜1.0 の範囲に正規化
end
```

### 4. ソートフェーズ

以下の優先順位でソート（すべて昇順）：

```lua
table.sort(results, function(a, b)
    -- 1. カテゴリー（1→2→3→4）
    if a.category ~= b.category then
        return a.category < b.category
    end
    
    -- 2. 正規化距離（小さいほど類似）
    if a.score ~= b.score then
        return a.score < b.score
    end
    
    -- 3. マッチ位置（前方ほど優先）
    if a.pos ~= b.pos then
        return a.pos < b.pos
    end
    
    -- 4. 文字列長（短いほど優先）
    if a.len ~= b.len then
        return a.len < b.len
    end
    
    -- 5. アルファベット順
    return a.item < b.item
end)
```

## 具体例での処理フロー

クエリ: "mini"
テキストリスト:
1. "mini"
2. "home/nvim/lua/plugins/mini-ai.lua"
3. "home/nvim/lua/plugins/mini-align.lua"
4. "home/nvim/lua/plugins/nvim_mini.lua"
5. "home/nvim/lua/plugins/ddu-source-cmdline_history.lua"
6. "home/nvim/lua/plugins/codecompanion-nvim.lua"

### ステップ1: カテゴリー判定結果
| テキスト | カテゴリー | 位置 | 理由 |
|---------|-----------|-----|------|
| "mini" | 1 | 1 | 完全一致 |
| "mini-ai.lua" | 2 | 23 | セグメント前方一致 |
| "mini-align.lua" | 2 | 23 | セグメント前方一致 |
| "nvim_mini.lua" | 3 | 30 | 部分文字列一致 |
| "cmdline_history.lua" | 4 | - | サブシーケンス |
| "codecompanion-nvim.lua" | 4 | - | サブシーケンス |

### ステップ2: 類似度スコア計算
各テキストのレーベンシュタイン距離と正規化距離を計算

### ステップ3: 最終ソート結果
1. "mini" （カテゴリー1、スコア0.0）
2. "mini-ai.lua" （カテゴリー2、より高い類似度）
3. "mini-align.lua" （カテゴリー2、より低い類似度）
4. "nvim_mini.lua" （カテゴリー3）
5. "codecompanion-nvim.lua" （カテゴリー4、より高い類似度）
6. "cmdline_history.lua" （カテゴリー4、より低い類似度）

## パフォーマンス最適化

1. **文字比較の高速化**: `string.byte` を使用してバイト単位で比較
2. **メモリ効率**: レーベンシュタイン距離計算で2行のみ使用
3. **早期終了**: カテゴリー判定で上位カテゴリーから順に判定し、該当したら即座に返す
4. **不要な計算の回避**: マッチしないアイテムは早期に除外

## 使用方法

```lua
local fuzzy_rank = require("fuzzy_rank")

local query = "mini"
local items = { ... }

-- 基本的な使用
local sorted = fuzzy_rank.rank(query, items)

-- 詳細情報付きで取得
local detailed = fuzzy_rank.rank(query, items, {
    return_details = true,
    case_sensitive = false
})
```