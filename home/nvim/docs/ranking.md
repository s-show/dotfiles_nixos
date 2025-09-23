## 曖昧検索の順位付け

曖昧検索でヒットしたテキストのリストを、以下の順番で順位付けして並べ替えしたい。

1. クエリ文字列と検索テキストが完全一致（`query: mini`, `text: mini`）
2. クエリ文字列と検索テキストの字数が違う & 検索テキストにクエリ文字列と一致する部分がある & 検索テキストの1文字目から一致が始まる（`query: mini`, `text: home/nvim/lua/plugins/mini-ai.lua`）
3. クエリ文字列と検索テキストの字数が違う & 検索テキストにクエリ文字列と一致する部分がある & 検索テキストの2文字目以降から一致が始まる（`query: mini`, `text: home/nvim/lua/plugins/nvim_mini.lua`）
4. 検索テキストにクエリ文字列と一致する部分はないが、クエリ文字列の各文字が検索テキストにクエリ文字列の順番通りに登場する（`query: mini`, `text: home/nvim/lua/plugins/ddu-source-cmdline_history.lua`）

上記の1から4でヒットするパターンが複数ある場合、ヒットしたパターン毎にレーベンシュタイン距離を計測し、そのレーベンシュタイン距離を `query` と `text` のうち長い方の文字列で割った値（類似度）が大きいものを優先する。

1. `text: home/nvim/lua/plugins/mini-ai.lua` と `text: home/nvim/lua/plugins/mini-align.lua` の2つでは、類似度が大きい `home/nvim/lua/plugins/mini-ai.lua` を優先する。
2. `text: home/nvim/lua/plugins/ddu-source-cmdline_history.lua` と `text: home/nvim/lua/plugins/codecompanion-nvim.lua` の2つでは、類似度が大きい `home/nvim/lua/plugins/codecompanion-nvim.lua` を優先する。

なお、テキストのリストは別途用意しているものとし、環境は Neovim の Lua とします。
