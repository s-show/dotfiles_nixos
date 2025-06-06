local function list_items()
	local items = {}
	local completion = require("codecompanion.providers.completion")
	for _, func in pairs({ "slash_commands", "tools", "variables" }) do
		for _, v in pairs(completion[func]()) do
			table.insert(
				items,
				{ word = v.label, info = v.detail, kind = v.type, user_data = { source = "codecompanion", raw = v } }
			)
		end
	end
	return items
end

local function patch_buffer()
	local sources = vim.fn["ddc#custom#get_global"]()["sources"] or {}
	table.insert(sources, 1, "parametric")
	vim.fn["ddc#custom#patch_buffer"]({
		sources = sources,
		specialBufferCompletion = true,
		sourceOptions = {
			parametric = {
				mark = "",
				minKeywordLength = 0,
				minAutoCompleteLength = 0,
				keywordPattern = "^[^\\s]*",
				matchers = {},
				converters = {},
				sorters = {},
			},
		},
		sourceParams = {
			parametric = { items = list_items() },
		},
	})
end

local function handle_slash_command(buffer)
	local augroup = vim.api.nvim_create_augroup("s_show-ddc-codecompanion-" .. buffer, {})

	vim.api.nvim_create_autocmd("BufDelete", {
		group = augroup,
		buffer = buffer,
		callback = function()
			vim.api.nvim_del_augroup_by_id(augroup)
		end,
	})

	vim.api.nvim_create_autocmd("User", {
		group = augroup,
		buffer = buffer,
		callback = function(ctx)
			if ctx.match ~= "PumCompleteDone" then
				return
			end
			local item = vim.g["pum#completed_item"]
			if not item.user_data or item.user_data.source ~= "codecompanion" then
				return
			end
			local chat = require("codecompanion.strategies.chat").buf_get_chat(buffer)
			require("codecompanion.providers.completion").slash_commands_execute(item.user_data.raw, chat)
		end,
	})
end

local function setup()
	local augroup = vim.api.nvim_create_augroup("s_show-ddc-codecompanion", {})
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "codecompanion",
		group = augroup,
		callback = function(ctx)
			local ok = pcall(require, "codecompanion")
			if not ok then
				return true -- remove autocmd
			end
			patch_buffer()
			handle_slash_command(ctx.buf)
		end,
	})
end

return setup
