local utils = require("utils")

---@class Scope
local Scope = {}

-- Gets the current scope, which is the root of the git repository if it exists, or the current working directory if it does not.
function Scope.get_scope()
	local cwd = vim.fn.getcwd()
	local root = vim.fs.root(cwd, ".git")
	return root or cwd
end

-- Encodes the current scope as a string that can be used as a file name.
-- This is done by encoding the scope as a JSON string and then encoding that string as base64 to ensure that it is a valid file name.
function Scope.get_encoded_scope()
	return utils.encode(Scope.get_scope())
end

-- Gets the file name for the current scope, which is the data directory followed by the encoded scope and a .json extension.
-- Ensures that the data directory exists before returning the file name.
function Scope.scope_file()
	utils.ensure_exists(utils.data_dir())

	local encoded_scope = Scope.get_encoded_scope()
	return utils.data_dir() .. "/" .. encoded_scope .. ".json"
end

return Scope
