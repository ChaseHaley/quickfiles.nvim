---@class WhichKey
local M = {}

---@param config QuickfilesWhichKey
function M:setup(config)
	if config == nil or not config.enabled then
		return
	end

	local ok, wk = pcall(require, "which-key")
	if not ok then
		return
	end

	wk.add({
		{
			config.jump_leader,
			group = "quickfiles",
			expand = function()
				return M:expand()
			end,
		},
	})
end

function M:expand()
	local mappings = {}
	for key, file in pairs(require("quickfiles"):list()) do
		table.insert(mappings, {
			key,
			function()
				require("quickfiles"):jump(key)
			end,
			desc = file,
		})
	end

	return mappings
end

return M
