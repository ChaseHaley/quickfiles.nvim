---@class Utils
local Utils = {}

-- Ensures that the provided directory exists, creating it if it does not.
---@param dir string
function Utils.ensure_exists(dir)
	if vim.fn.isdirectory(dir) == 0 then
		vim.fn.mkdir(dir, "p")
	end
end

-- Returns the file name of the provided buffer (defaults to current buffer if none is provided).
-- Returns `nil` if no file exists in the provided buffer.
---@param bufnr? number | string
---@return string | nil
function Utils.get_buffer_file(bufnr)
	if bufnr == nil then
		bufnr = "%"
	end

	local file = vim.fn.bufname(bufnr)

	if file == "" then
		vim.notify("quickfiles: current buffer " .. bufnr .. " has no file", vim.log.levels.WARN)
		return nil
	end

	return file
end

-- Encodes the provided value as a URI component using the RFC 2396 standard.
---@param value string
function Utils.encode(value)
	return vim.uri_encode(value, "rfc2396")
end

-- Returns the data directory for quickfiles, which is the standard data directory for Neovim followed by a "quickfiles" subdirectory.
function Utils.data_dir()
	return vim.fn.stdpath("data") .. "/quickfiles"
end

-- Prompts the user for a key and returns it, translating any special keys to their string representations.
function Utils.read_key()
	return vim.fn.keytrans(vim.fn.getcharstr())
end

return Utils
