local utils = require("utils")
local StateManager = require("state_manager")
local wk = require("which_key_ext")
local config = require("config")
local snacks_ext = require("snacks_ext")

---@class Quickfiles
--- @field state_manager StateManager
local Quickfiles = {}
Quickfiles.__index = Quickfiles

-- Creates a new instance of the Quickfiles class.
function Quickfiles:new()
	return setmetatable({
		state_manager = StateManager:new(),
	}, self)
end

-- Removes all keys that point to the provided buffer (defaults to current buffer if none is provided).
---@param bufnr? number | string
function Quickfiles:remove(bufnr)
	if bufnr == nil then
		bufnr = "%"
	end

	self.state_manager:remove(bufnr)
end

-- Removes all marks.
function Quickfiles:clear()
	self.state_manager:clear()
end

-- Removes the mark associated with the key provided by the user.
-- If no key is provided, prompts the user for a key to clear.
---@param key? string
function Quickfiles:clear_key(key)
	if key == nil then
		key = utils.read_key()
	end

	if key == "" or key == "<Esc>" then
		return
	end

	self.state_manager:clear_key(key)
end

-- Marks the provided buffer (defaults to current buffer if none is provided) with a key provided by the user.
---@param bufnr? number
---@param key? string
function Quickfiles:mark(bufnr, key)
	if key == nil then
		key = utils.read_key()
	end

	if key == "" or key == "<Esc>" then
		return
	end

	local file = utils.get_buffer_file(bufnr)
	if not file then
		return
	end

	self.state_manager:update(key, file)

	vim.notify(("quickfiles: marked %s -> %s"):format(key, vim.fn.fnamemodify(file, ":~:.")))
end

-- Jumps to the file marked by the key provided by the user.
function Quickfiles:jump(key)
	if key == nil then
		key = utils.read_key()
	end

	if key == "" or key == "<Esc>" then
		return
	end

	local file = self.state_manager:get_value(key)

	if not file then
		vim.notify(("quickfiles: no file marked for %s"):format(key), vim.log.levels.WARN)
		return
	end

	--[[ local bufnr = vim.fn.bufnr(file, true)
	if not vim.api.nvim_buf_is_loaded(bufnr) then
		local group = vim.api.nvim_create_augroup("QuickfilesSwap", { clear = true })
		vim.api.nvim_create_autocmd("SwapExists", {
			group = group,
			pattern = "*",
			callback = function()
				vim.v.swapchoice = "e" -- edit anyway (no recovery prompt)
			end,
		})
		local ok, err = pcall(vim.fn.bufload, file)
		vim.api.nvim_del_augroup_by_id(group)
		if not ok then
			vim.notify(("quickfiles: failed to load %s: %s"):format(file, err), vim.log.levels.ERROR)
		else
			vim.api.nvim_set_option_value("buflisted", true, { buf = bufnr })
		end
	end

	vim.api.nvim_set_current_buf(bufnr) ]]
	vim.schedule(function()
		local bufnr = vim.fn.bufnr(file, true)
		if not vim.api.nvim_buf_is_loaded(bufnr) then
			local save = vim.o.shortmess
			vim.opt.shortmess:append("A")
			pcall(vim.fn.bufload, file)
			vim.o.shortmess = save
			vim.api.nvim_set_option_value("buflisted", true, { buf = bufnr })
		end
		vim.api.nvim_set_current_buf(bufnr)
	end)
end

-- Returns a copy of the current state of the quickfiles marks.
---@return table
function Quickfiles:list()
	return vim.deepcopy(self.state_manager:get_state())
end

function Quickfiles:pick()
	return snacks_ext.pick()
end

local quickfiles = Quickfiles:new()

-- Sets up the quickfiles plugin with the provided configuration.
-- Merges the provided configuration with the default configuration.
---@param partial_config QuickfilesConfig.partial
function Quickfiles.setup(partial_config)
	local new_config = config.merge(partial_config)
	wk:setup(new_config.which_key)
end

return quickfiles
