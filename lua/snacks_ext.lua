local M = {}

function M.pick()
	local ok, snacks = pcall(require, "snacks")
	if not ok then
		return
	end

	local quickfiles = require("quickfiles")
	local items = {}
	for key, file in pairs(quickfiles:list()) do
		items[#items + 1] = {
			text = key .. " " .. file,
			file = file,
			key = key,
		}
	end

	snacks.picker.pick({
		items = items,
		format = "file",
		confirm = function(picker, item)
			picker:close()
			quickfiles:jump(item.key)
		end,
	})
end

return M
