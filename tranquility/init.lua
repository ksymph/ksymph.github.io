Util = {
	markdown = require "tranquility.markdown",
	templite = require "tranquility.templite",
	lfs = require "lfs"
}

local tranquility = {}

-- Helper functions (read_file, write_file)
local function read_file(path) local f = io.open(path, "r"); if not f then return nil end; local c = f:read("*a"); f:close(); return c end
local function write_file(path, content) local i, j = 1, 0; while true do j = path:find("/", i); if not j then break end; lfs.mkdir(path:sub(1, j - 1)); i = j + 1 end; local f = io.open(path, "w"); if not f then return end; f:write(content); f:close() end


-- Step 1: Discover and parse all content collections from the content directory.
function tranquility:load_collections()
	self.site.collections = {}
	local content_root = self.base_dir .. "/" .. self.config.content_dir
	
	for collection_name in Util.lfs.dir(content_root) do
		if collection_name ~= "." and collection_name ~= ".." then
			local collection_path = content_root .. "/" .. collection_name
			if Util.lfs.attributes(collection_path, "mode") == "directory" then
				print("  -> Found collection: " .. collection_name)
				self.site.collections[collection_name] = {}
				
				for file in Util.lfs.dir(collection_path) do
					if file:match("%.md$") then
						local data = {}
						data.raw = read_file(collection_path .. "/" .. file)
						
						data.slug = file:gsub("%.md$", "")
						data.url = "/" .. collection_name .. "/" .. data.slug .. ".html"
						
						table.insert(self.site.collections[collection_name], data)
					end
				end
			end
		end
	end
end

-- Step 2: Process the static directory. Copy assets, render .lua files
function tranquility:process_static_dir(path, rel_path)
	for file in Util.lfs.dir(path) do
		if file ~= "." and file ~= ".." then
			local full_path = path .. "/" .. file
			local next_rel_path = (rel_path and (rel_path .. "/") or "") .. file

			if Util.lfs.attributes(full_path, "mode") == "directory" then
				self:process_static_dir(full_path, next_rel_path)
			elseif file:match("%.lua$") then
				print("  -> Rendering page: " .. next_rel_path)
				local out_path = "/" .. next_rel_path:gsub("%.lua$", "")
				local content_func = dofile(full_path)
				self.output[out_path] = content_func(self.site)
			else
				print("  -> Copying static asset: " .. next_rel_path)
				self.output["/" .. next_rel_path] = read_file(full_path)
			end
		end
	end
end

-- Step 3: Render all items from the loaded collections.
function tranquility:render_collections()
	for name, collection in pairs(self.site.collections) do
		-- Convention: Template is named after the collection.
		local template_path = self.base_dir .. "/" .. self.config.template_dir .. "/" .. name
		template_path = template_path:gsub("/", "."):match("%w.*")
		local ok, template_func = pcall(require, template_path)
		if not ok then
			print("  -> Warning: No template found for collection '"..name.."' at "..template_path..". Skipping.")
		else
			for _, item in ipairs(collection) do
				print("  -> Rendering item: " .. item.url)
				self.output[item.url] = template_func(item)
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
	self:process_static_dir(self.base_dir .. "/" .. self.config.static_dir)
	self:render_collections()
	
	-- Write all generated files to the output directory
	local out_dir = self.base_dir .. "/" .. self.config.out_dir
	print("Writing files to " .. out_dir .. "...")
	Util.lfs.mkdir(out_dir)
	for path, content in pairs(self.output) do
		write_file(out_dir .. path, content)
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