local function parse(str, environment)
	local env = setmetatable(environment or {}, { __index = _G })
	local code = [[
		local result = ''
		local function rwrite(s) result = result .. tostring(s or '') end
		local function write(s)
			if s == nil then s = '' end
			result = result .. tostring(s):gsub("&", "&"):gsub("<", "<"):gsub(">", ">"):gsub("\"", """):gsub("'", "'"):gsub("/", "/")
		end
		rwrite[=[
	]]
	code = code .. str:
		gsub("[][]=[][]", ']=]rwrite"%1"rwrite[=['): -- Escape [[]]
		gsub("<%%=", "]=]write("):  -- <%= value %> (escaped)
		gsub("<%%-", "]=]rwrite("): -- <%- value %> (raw)
		gsub("<%%", "]=] "):      -- <% Lua code %> (control flow)
		gsub("%%>", " rwrite[=[")

	code = code .. "]=] return result"

	local func, err = loadstring(code, "template", "t", env)
	if not func then
		error("Error compiling template: " .. (err or "unknown error") .. "\nGenerated code:\n" .. code)
	end
	return func()
end

return parse