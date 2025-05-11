local tinysegmenter = require("tinysegmenter")

-- @desc: 引数で渡された文字が ASCII 文字かそうでないか判断する関数
-- @param - string
function IsASCIIChar(char)
  if vim.fn.strcharlen(char) > 1 then
    return false
  end
  local char_byte_count = string.len(char)
  if char_byte_count == 1 then
    return true
  else
    return false
  end
end

function OverrideWordMotion(arg)
  if IsASCIIChar(arg.under_cursor_char) then
    -- `bang = true` とすると `normal!` と同じことになる
    vim.cmd.normal({ arg.motion, bang = true })
  else
    local parsed_text_with_position = {}
    local text_start_position = 1
    for i, text in ipairs(arg.parsed_text) do
      parsed_text_with_position[i] = {}
      parsed_text_with_position[i]['text'] = text
      parsed_text_with_position[i]['start'] = text_start_position
      parsed_text_with_position[i]['end'] = text_start_position + vim.fn.strcharlen(text) - 1
      text_start_position = text_start_position + vim.fn.strcharlen(text)
    end
    for i, text_with_position in ipairs(parsed_text_with_position) do
      if arg.cursor_position[3] >= text_with_position['start'] + arg.first_char_position - 1 and
         arg.cursor_position[3] <= text_with_position['end']   + arg.first_char_position - 1 then
        -- vim.notify('arg.cursor_position[3]: ' .. tostring(arg.cursor_position[3]))
        -- vim.notify('arg.first_char_position: ' .. tostring(arg.first_char_position))
        -- vim.notify('arg.last_char_position: ' .. tostring(arg.last_char_position))
        -- vim.notify("text " .. tostring(text_with_position['text']))
        -- vim.notify("text_with_position['start'] " .. tostring(text_with_position['start']))
        -- vim.notify("text_with_position['end'] " .. tostring(text_with_position['end']))
        if arg.motion == 'w' then
          -- カーソルが非空白文字の末尾 or 分かち書きした文字列の最後のノードにある
          if arg.cursor_position[3] == arg.last_char_position or
            text_with_position['end'] + arg.first_char_position - 1 == arg.last_char_position then
            local below_line_text = vim.fn.getline(arg.cursor_position[2] + 1)
            local first_char_position = vim.fn.matchstrpos(below_line_text, '^\\s\\+')[3] + 1
            arg.cursor_position[3] = first_char_position
            arg.cursor_position[2] = arg.cursor_position[2] + 1
          elseif i ~= #parsed_text_with_position then
            arg.cursor_position[3] = parsed_text_with_position[i + 1]['start'] + arg.first_char_position - 1
          end
        end
        if arg.motion == 'ge' then
          -- カーソルが非空白文字の始め or 分かち書きした文字列の最初のノードにある
          if arg.cursor_position[3] == arg.first_char_position or
            text_with_position['start'] + arg.first_char_position - 1 == arg.first_char_position then
            local above_line_text = vim.fn.getline(arg.cursor_position[2] - 1)
            local last_char_position = vim.fn.strcharlen(vim.fn.substitute(above_line_text, '\\s\\+\\_$', '', 'g'))
            arg.cursor_position[3] = last_char_position
            arg.cursor_position[2] = arg.cursor_position[2] - 1
          elseif i ~= 1 then
            arg.cursor_position[3] = parsed_text_with_position[i - 1]['end'] + arg.first_char_position - 1
          end
        end
        if arg.motion == 'b' then
          -- カーソルが非空白文字の始めにある
          if arg.cursor_position[3] == arg.first_char_position then
            local above_line_text = vim.fn.getline(arg.cursor_position[2] - 1)
            local above_line_text_without_space = vim.fn.substitute(above_line_text, '\\s\\+\\_$', '', 'g')
            local above_line_text_without_space_length = vim.fn.strcharlen(above_line_text_without_space)
            local parsed_above_line_text = tinysegmenter.segment(above_line_text_without_space)
            arg.cursor_position[3] = above_line_text_without_space_length - vim.fn.strcharlen(parsed_above_line_text[#parsed_above_line_text]) + 1
            arg.cursor_position[2] = arg.cursor_position[2] - 1
          -- カーソルが分かち書きした文字列の最初のノードにある
          elseif text_with_position['start'] + arg.first_char_position - 1 == arg.first_char_position then
            arg.cursor_position[3] = text_with_position['start'] + arg.first_char_position - 1
          elseif i ~= 1 then
            -- カーソルが分かち書きした各ノードの1文字目にある
            if arg.cursor_position[3] == text_with_position['start'] + arg.first_char_position - 1 then
              arg.cursor_position[3] = parsed_text_with_position[i - 1]['start'] + arg.first_char_position - 1
            else
              arg.cursor_position[3] = text_with_position['start'] + arg.first_char_position - 1
            end
          end
        end
        if arg.motion == 'e' then
          -- カーソルが非空白文字の末尾にある
          if arg.cursor_position[3] == arg.last_char_position then
            local below_line_text = vim.fn.getline(arg.cursor_position[2] + 1)
            local below_line_text_without_space = vim.fn.substitute(below_line_text, '^\\s\\+', '', 'g')
            local first_char_position = vim.fn.matchstrpos(below_line_text, '^\\s\\+')[3] + 1
            -- 行頭に空白が無いと first_char_position が 0 になるので、強制的に値を 1 にする
            if first_char_position == 0 then
              first_char_position = first_char_position + 1
            end
            local parsed_below_line_text = tinysegmenter.segment(below_line_text_without_space)
            arg.cursor_position[3] = vim.fn.strcharlen(parsed_below_line_text[1]) + first_char_position - 1
            arg.cursor_position[2] = arg.cursor_position[2] + 1
            -- カーソルが分かち書きした文字列の最後のノードにある
          elseif text_with_position['end'] + arg.first_char_position - 1 == arg.last_char_position then
            arg.cursor_position[3] = text_with_position['end'] + arg.first_char_position - 1
          elseif i ~= #parsed_text_with_position then
            -- カーソルが分かち書きした各ノードの最後の文字にある
            if arg.cursor_position[3] == text_with_position['end'] + arg.first_char_position - 1 then
              arg.cursor_position[3] = parsed_text_with_position[i + 1]['end'] + arg.first_char_position - 1
            else
              arg.cursor_position[3] = text_with_position['end'] + arg.first_char_position - 1
            end
          end
        end
        vim.fn.setcursorcharpos(arg.cursor_position[2], arg.cursor_position[3])
        break
      end
    end
  end
end

for _, motion in ipairs({'w', 'b', 'e', 'ge'}) do
  vim.keymap.set('n', motion, function ()
    -- コマンドの指定回数を取得する。回数が指定されていない場合の値は 1 である。
    local count1 = vim.v.count1
    while count1 > 0 do
      local cursor_line_text = vim.fn.getline('.')
      -- 行末の空白文字を残して分かち書き処理すると後処理が面倒なので削除する
      local cursor_line_text_without_eol_space = vim.fn.substitute(cursor_line_text, '\\s\\+\\_$', '', 'g')
      -- 行頭の空白文字も残すと後処理が面倒なので削除する
      local cursor_line_text_without_space = vim.fn.substitute(cursor_line_text_without_eol_space, '^\\s\\+', '', 'g')
      -- `b`, `ge` はカーソルが非空白文字の始めにあれば処理を分岐するので、非空白文字の始めの位置を取得しておく。
      -- matchstrpos はパターンが1文字目に見つかったらインデックスを `0` `と返す
      local first_char_position = vim.fn.matchstrpos(cursor_line_text, '^\\s\\+')[3] + 1
      -- 行頭に空白が無いと first_char_position が 0 になるので、強制的に値を 1 にする
      if first_char_position == 0 then
        first_char_position = first_char_position + 1
      end
      -- `w`, `e` はカーソルが非空白文字の末尾にあれば処理を分岐するので、非空白文字の末尾の位置を取得しておく。
      local last_char_position = vim.fn.strcharlen(cursor_line_text_without_eol_space)
      local parsed_text = tinysegmenter.segment(cursor_line_text_without_space)
      -- カーソル下の文字の取得は https://eagletmt.hatenadiary.org/entry/20100623/1277289728 を参照した
      local under_cursor_char = vim.fn.matchstr(cursor_line_text, '.', vim.fn.col('.')-1)
      local cursor_position = vim.fn.getcursorcharpos()
      OverrideWordMotion({
        motion = motion,
        cursor_line_text = cursor_line_text,
        parsed_text = parsed_text,
        cursor_position = cursor_position,
        under_cursor_char = under_cursor_char,
        first_char_position = first_char_position,
        last_char_position = last_char_position
      })
      count1 = count1 - 1
    end
  end)
end
