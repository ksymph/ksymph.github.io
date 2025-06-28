Util = {
	markdown = require "tranquility.markdown",
	templite = require "tranquility.templite",
	lfs = require "lfs"
}

local tranquility = {}

-- Create environment for loaded chunks with access to Util and global functions
local function make_env()
	local env = { Util = Util }
	setmetatable(env, { __index = _G })
	return env
end

Util.read = function(path)
	local f = io.open(path, "r")
	if not f then return nil end
	local content = f:read("*a")
	f:close()
	return content
end

Util.write = function(path, content)
	-- Create parent directories if they don't exist
	local dir = path:match("(.*)/")
	if dir and dir ~= "" then
		Util.lfs.mkdir(dir)
	end
	local f = io.open(path, "w")
	if not f then return false end
	f:write(content)
	f:close()
	return true
end

-- Step 1: Discover and parse all content collections from the content directory.
function tranquility:load_collections()
	self.site.collections = {}
	self.site.templates = {} -- Initialize templates table
	local content_root = self.base_dir .. "/" .. self.config.content_dir
	local template_dir = self.base_dir .. "/" .. self.config.template_dir

	-- Load all templates first
	print("Loading templates...")
	for file in Util.lfs.dir(template_dir) do
		if file:match("%.lua$") then
			local template_path = template_dir .. "/" .. file
			local chunk, err = loadfile(template_path)
			if not chunk then
				print("  -> Error loading template: " .. template_path .. ": " .. err)
			else
				setfenv(chunk, make_env())
				local ok, template_func = pcall(chunk)
				if not ok then
					print("  -> Error running template: " .. template_path .. ": " .. template_func)
				elseif type(template_func) ~= "function" then
					print("  -> Template did not return a function: " .. template_path)
				else
					local name = file:gsub("%.lua$", "")
					self.site.templates[name] = template_func
					print("  -> Loaded template: " .. name)
				end
			end
		end
	end

	-- Load content collections
	for collection_name in Util.lfs.dir(content_root) do
		if collection_name ~= "." and collection_name ~= ".." then
			local collection_path = content_root .. "/" .. collection_name
			if Util.lfs.attributes(collection_path, "mode") == "directory" then
				print("  -> Found collection: " .. collection_name)
				self.site.collections[collection_name] = {}

				for file in Util.lfs.dir(collection_path) do
					if file:match("%.md$") then
						local data = {}
						local file_path = collection_path .. "/" .. file
						data.raw = Util.read(file_path)
						if not data.raw then
							print("  -> Error reading file: " .. file_path)
						else
							data.slug = file:gsub("%.md$", "")
							data.url = "/" .. collection_name .. "/" .. data.slug .. ".html"
							table.insert(self.site.collections[collection_name], data)
						end
					end
				end
			end
		end
	end
end

-- Step 2: Process the static directory. Copy assets, render .lua files
function tranquility:process_static_dir(path, rel_path)
	rel_path = rel_path or ""
	for file in Util.lfs.dir(path) do
		if file ~= "." and file ~= ".." then
			local full_path = path .. "/" .. file
			local next_rel_path = (rel_path ~= "" and (rel_path .. "/") or "") .. file

			if Util.lfs.attributes(full_path, "mode") == "directory" then
				self:process_static_dir(full_path, next_rel_path)
			elseif file:match("%.lua$") then
				print("  -> Rendering page: " .. next_rel_path)
				local out_path = "/" .. next_rel_path:gsub("%.lua$", "")
				local chunk, err = loadfile(full_path)
				if not chunk then
					print("  -> Error loading Lua file: " .. full_path .. ": " .. err)
				else
					setfenv(chunk, make_env())
					local ok, content_func = pcall(chunk)
					if not ok then
						print("  -> Error running Lua file: " .. full_path .. ": " .. content_func)
					elseif type(content_func) ~= "function" then
						print("  -> Lua file did not return a function: " .. full_path)
					else
						self.output[out_path] = content_func(self.site)
					end
				end
			else
				print("  -> Copying static asset: " .. next_rel_path)
				self.output["/" .. next_rel_path] = Util.read(full_path)
			end
		end
	end
end

-- Step 3: Render all items from the loaded collections.
function tranquility:render_collections()
	for name, collection in pairs(self.site.collections) do
		-- Get template from preloaded templates
		local template_func = self.site.templates[name]

		if not template_func then
			print("  -> Warning: No template found for collection '" .. name .. "'. Skipping.")
		else
			for _, item in ipairs(collection) do
				print("  -> Rendering item: " .. item.url)
				-- Pass both item and site to template function
				self.output[item.url] = template_func(item, self.site)
			end
		end
	end
end

-- Main build function
function tranquility:build()
	self.output = {}
	self.site = {}

	print("Building site...")

	-- The order is critical: load content first so templates can use it.
	self:load_collections()
	self:render_collections()
	self:process_static_dir(self.base_dir .. "/" .. self.config.static_dir)

	-- Write all generated files to the output directory
	local out_dir = self.base_dir .. "/" .. self.config.out_dir
	print("Writing files to " .. out_dir .. "...")
	Util.lfs.mkdir(out_dir)
	for path, content in pairs(self.output) do
		Util.write(out_dir .. path, content)
	end

	print("Build complete.")
end

-- Entry point
local base_dir = ...
if not base_dir then
	print("Error: Missing input directory path.")
	return
end

tranquility.base_dir = base_dir
tranquility.config = dofile(base_dir .. "/config.lua")

tranquility:build()
