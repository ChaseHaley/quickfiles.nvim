---@class QuickfilesConfig
---@field which_key QuickfilesWhichKey

---@class QuickfilesWhichKey
---@field enabled boolean
---@field jump_leader? string

---@class QuickfilesWhichKey.partial
---@field enabled? boolean
---@field jump_leader? string

---@class QuickfilesConfig.partial
---@field which_key? QuickfilesWhichKey.partial

local M = {}
---@type QuickfilesConfig
M.defaults = { which_key = { enabled = false } }

---@param partial QuickfilesConfig.partial
function M.merge(partial)
	local cfg = vim.tbl_deep_extend("force", vim.deepcopy(M.defaults), partial or {})
	return cfg
end

return M
