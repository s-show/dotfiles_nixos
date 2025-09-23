-- fuzzy_rank.lua
-- 曖昧検索のランキングアルゴリズム実装
-- カテゴリー優先順位: 完全一致 > 前方一致 > 部分文字列 > サブシーケンス
-- 同一カテゴリー内は正規化レーベンシュタイン距離でソート

local M = {}

-- 小文字変換（大文字小文字を無視するため）
local function norm(s)
  return string.lower(s or "")
end

-- クエリがテキストのサブシーケンスかをチェック
-- 文字が順番通りに出現すればOK（連続でなくても良い）
local function is_subsequence(query, text)
  local qi, qn = 1, #query
  if qn == 0 then return true end
  for i = 1, #text do
    if string.byte(text, i) == string.byte(query, qi) then
      qi = qi + 1
      if qi > qn then return true end
    end
  end
  return false
end

-- パスをセグメントに分割するイテレータ
local function iter_path_segments(s)
  local start = 1
  local len = #s
  return function()
    if start > len then return nil end
    local i = string.find(s, "/", start, true)
    if i == nil then
      local seg = string.sub(s, start, len)
      start = len + 1
      return seg
    else
      local seg = string.sub(s, start, i - 1)
      start = i + 1
      return seg
    end
  end
end

-- カテゴリー判定
-- 戻り値: カテゴリー番号(1-4) or nil, マッチ位置
local function categorize(query_lc, text_lc)
  -- カテゴリー1: 完全一致
  if text_lc == query_lc then
    return 1, 1
  end

  -- カテゴリー2: 前方一致（テキスト全体）
  if string.sub(text_lc, 1, #query_lc) == query_lc then
    return 2, 1
  end

  -- カテゴリー2: 前方一致（パスセグメント）
  for seg in iter_path_segments(text_lc) do
    if #seg > 0 and string.sub(seg, 1, #query_lc) == query_lc then
      -- セグメントの開始位置を取得
      local pos = string.find(text_lc, seg, 1, true) or 1
      return 2, pos
    end
  end

  -- カテゴリー3: 部分文字列
  local s, e = string.find(text_lc, query_lc, 1, true)
  if s ~= nil then
    return 3, s
  end

  -- カテゴリー4: サブシーケンス
  if is_subsequence(query_lc, text_lc) then
    return 4, nil
  end

  return nil, nil
end

-- レーベンシュタイン距離（メモリ効率版）
local function levenshtein(a, b)
  local la, lb = #a, #b
  if la == 0 then return lb end
  if lb == 0 then return la end
  
  -- 短い方を a にする（キャッシュ効率のため）
  if la > lb then
    a, b, la, lb = b, a, lb, la
  end

  local prev = {}
  local curr = {}

  -- 初期化
  for j = 0, lb do
    prev[j] = j
  end

  -- DP計算
  for i = 1, la do
    curr[0] = i
    local ai = string.byte(a, i)
    for j = 1, lb do
      local cost = (ai == string.byte(b, j)) and 0 or 1
      local del = prev[j] + 1
      local ins = curr[j - 1] + 1
      local sub = prev[j - 1] + cost
      local v = del
      if ins < v then v = ins end
      if sub < v then v = sub end
      curr[j] = v
    end
    prev, curr = curr, prev
  end

  return prev[lb]
end

-- 正規化距離（0.0〜1.0）
local function normalized_distance(a, b)
  local la, lb = #a, #b
  if la == 0 and lb == 0 then return 0 end
  local d = levenshtein(a, b)
  local m = (la > lb) and la or lb
  return d / m
end

-- メイン関数：アイテムをランキング順にソート
-- @param query: 検索クエリ
-- @param items: 文字列のリスト
-- @param opts: オプション
--   - return_details: 詳細情報を返すか（デフォルト: false）
--   - case_sensitive: 大文字小文字を区別するか（デフォルト: false）
-- @return: ソート済みリスト（またはdetailsテーブル）
function M.rank(query, items, opts)
  opts = opts or {}
  if type(query) ~= "string" then
    error("query must be a string")
  end
  if type(items) ~= "table" then
    error("items must be a list/table of strings")
  end

  local case_sensitive = opts.case_sensitive == true

  local q_cmp = case_sensitive and query or norm(query)
  local results = {}

  -- 各アイテムをカテゴライズし、スコアを計算
  for _, item in ipairs(items) do
    local t_cmp = case_sensitive and item or norm(item)
    local cat, pos = categorize(q_cmp, t_cmp)
    if cat ~= nil then
      local score = normalized_distance(q_cmp, t_cmp)
      table.insert(results, {
        item = item,
        category = cat,
        score = score,
        pos = pos or math.huge,
        len = #t_cmp,
      })
    end
  end

  -- ソート: カテゴリー > スコア > 位置 > 長さ > アルファベット順
  table.sort(results, function(a, b)
    if a.category ~= b.category then
      return a.category < b.category
    end
    if a.score ~= b.score then
      return a.score < b.score
    end
    if a.pos ~= b.pos then
      return a.pos < b.pos
    end
    if a.len ~= b.len then
      return a.len < b.len
    end
    return a.item < b.item
  end)

  if opts.return_details then
    return results
  else
    local out = {}
    for i = 1, #results do
      out[i] = results[i].item
    end
    return out
  end
end

return M