if vim.o.buftype == "help" then
	vim.cmd("wincmd L | vertical resize 83") -- 幅は少し余裕を持たせている
end
