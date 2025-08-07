print("Starting build process...")

local function read(path)
	local file = io.open(path, "r")
	local content = file:read("*a")
	file:close()
	return content
end

local function write(path, content)
	local file = io.open(path, "w")
	file:write(content)
	file:close()
end

-- get list of post files
local posts = {}
local handle = io.popen("ls posts/*.html")
for file in handle:lines() do
    table.insert(posts, file)
end
handle:close()
print("Found " .. #posts .. " post files.")

-- process posts
print("Processing posts...")
local parsed_posts = {}
for _, filepath in ipairs(posts) do
    local content = read(filepath)

    local filename = filepath:match("posts/(.*)%.html")
    local title = content:match("<h1>(.-)</h1>")
    local datetime = content:match('<time datetime="([^"]*)"')
    local display_time = content:match('<time[^>]*>(.-)</time>')
    local body_content = content:match('<time[^>]*>.-</time>%s*(.*)')

    table.insert(parsed_posts, {
        id = filename,
        title = title,
        datetime = datetime,
        display_time = display_time,
        content = body_content
    })
    print("Processed post: " .. filename)
end
print("Finished processing posts. Total parsed: " .. #parsed_posts)

-- build blog.html
print("Building blog.html...")
do
	local blog = read("blog.html")

	local nav_links = ""
	for _, post in ipairs(parsed_posts) do
	    nav_links = nav_links .. '\t\t\t<a href="#' .. post.id .. '">' .. post.title .. '</a>\n'
	end

	local articles = ""
	for _, post in ipairs(parsed_posts) do
	    articles = articles .. '\t\t\t<article id="' .. post.id .. '">\n'
	    articles = articles .. '\t\t\t\t<h2><a href="#' .. post.id .. '">' .. post.title .. '</a></h2>\n'
	    articles = articles .. '\t\t\t\t<time datetime="' .. post.datetime .. '">' .. post.display_time .. '</time>\n'
	    articles = articles .. '\t\t\t\t' .. post.content .. '\n'
	    articles = articles .. '\t\t\t</article>\n'
	end

	blog = blog:gsub('{{nav_links}}', nav_links)
	blog = blog:gsub('{{posts}}', articles)

	write("public/blog.html", blog)
end
print("Finished building public/blog.html")

-- build feed.xml
print("Building feed.xml...")
do
	local feed = read("feed.xml")
	local current_date = os.date("!%Y-%m-%dT%H:%M:%SZ")

	-- Generate entries
	local entries = ""
	for _, post in ipairs(parsed_posts) do
	    local entry_template = [[
	  <entry>
	    <title>]] .. post.title .. [[</title>
	    <link href="https://ksymph.github.io/blog#]] .. post.id .. [[" />
	    <id>https://ksymph.github.io/blog/posts/]] .. post.id .. [[</id>
	    <updated>]] .. post.datetime .. [[</updated>
	    <content type="html">
	      ]] .. post.content:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;") .. [[
	    </content>
	    <author>
	      <name>K</name>
	    </author>
	  </entry>]]
	    entries = entries .. entry_template .. "\n"
	end

	feed = feed:gsub("{{updated}}", current_date)
	feed = feed:gsub('{{entries}}', entries)

	write("public/feed.xml", feed)
end
print("Finished building public/feed.xml")
print("Build process completed successfully.")
