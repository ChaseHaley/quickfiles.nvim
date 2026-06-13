local M = {}

local state = {}

local function current_file()
	local file = vim.api.nvim_buf_get_name(0)

	if file == "" then
		vim.notify("quickfiles: current buffer has no file", vim.log.levels.WARN)
		return nil
	end

	return vim.fn.fnamemodify(file, ":p")
end

function M.mark()
	local key = vim.fn.getcharstr()

	if key == "" or key == "<Esc>" then
		return
	end

	local file = current_file()
	if not file then
		return
	end

	state[key] = file

	vim.notify(("quickfiles: marked %s -> %s"):format(key, vim.fn.fnamemodify(file, ":~:.")))
end

function M.jump()
	local key = vim.fn.getcharstr()

	if key == "" or "<Esc>" then
		return
	end

	local file = state[key]

	if not file then
		vim.notify(("quickfiles: no file marked for %s"):format(key), vim.log.levels.WARN)
		return
	end

	vim.cmd.edit(vim.fn.fnameescape(file))
end

function M.list()
	return vim.deepcopy(state)
end

return M
