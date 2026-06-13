local utils = require("utils")
local scope = require("scope")

---@class StateManager
---@field cache table
local StateManager = {}
StateManager.__index = StateManager

-- Creates a new instance of the StateManager class.
function StateManager:new()
	return setmetatable({
		cache = {},
	}, self)
end

-- Loads the state of the quickfiles marks from the data file. If the data directory or file does not exist, it creates them and returns an empty state.
---@return table
function StateManager:load_state()
	local cachedState = self.cache[scope.get_encoded_scope()]
	if cachedState ~= nil then
		return cachedState
	end

	utils.ensure_exists(utils.data_dir())

	local data_file_name = scope.scope_file()
	if vim.fn.filereadable(data_file_name) == 1 then
		local lines = vim.fn.readfile(data_file_name)
		local json = table.concat(lines, "\n")
		local data = vim.json.decode(json)
		return data
	end

	return {}
end

-- Saves the state of the quickfiles marks to the data file.
---@param new_state table
function StateManager:save_state(new_state)
	local json = vim.json.encode(new_state)
	vim.fn.writefile({ json }, scope:scope_file())
end

-- Removes all keys that point to the provided buffer (defaults to current buffer if none is provided).
---@param bufnr? number | string
function StateManager:remove(bufnr)
	local new_state = self:load_state()
	for key, value in pairs(self:load_state()) do
		if value == utils.get_buffer_file(bufnr) then
			new_state[key] = nil
		end
	end

	self:save_state(new_state)
end

-- Marks the provided buffer (defaults to current buffer if none is provided) with a key provided by the user.
---@param key string
---@param file string
function StateManager:update(key, file)
	local new_state = self:load_state()
	new_state[key] = file
	self:save_state(new_state)
end

-- Returns the file marked by the provided key. If no key is provided, returns a copy of the entire state.
---@param key string
---@return string | nil
function StateManager:get_value(key)
	return self:load_state()[key]
end

-- Returns a copy of the entire state.
function StateManager:get_state()
	return vim.deepcopy(self:load_state())
end

-- Removes all marks.
function StateManager:clear()
	self:save_state({})
end

-- Removes the mark associated with the key provided by the user.
---@param key string
function StateManager:clear_key(key)
	local new_state = self:get_state()
	new_state[key] = nil
	self:save_state(new_state)
end

return StateManager
