local function format_date(unixtime)
	local days = { "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" }
	local months = { "January", "February", "March", "April", "May", "June", "July",
		"August", "September", "October", "November", "December" }
	local d = os.date("*t", unixtime)
	return string.format("%s, %d %s %d", days[d.wday], d.day, months[d.month], d.year)
end

local function build_post(post)
	local post_str = ""
	local post_raw, err = Util.read("public" .. url)
	post_str = '<article class="blog-post">' .. markdown(post_raw) .. "</article>"

	post_str = post_str:gsub("<h1>", "<header><a href=" .. url:gsub(".md$", "") .. "><h1>")
	post_str = post_str:gsub("</h1>", "</a></h1>")

	local days = { "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" }
	local months = { "January", "February", "March", "April", "May", "June", "July", "August", "September", "October",
		"November", "December" }
	local unixtime = 0
	post_str = post_str:gsub("<h2>(.*)</h2>", function(timestamp)
		unixtime = tonumber(timestamp)
		local time = luatz.timetable.new_from_timestamp(unixtime)
		return "<time datetime=" .. time:rfc_3339() .. ">" ..
			 days[time.wday] .. ", " .. time.day .. " " .. months[time.month] .. " " .. time.year .. "</time></header>"
	end)

	post_str = post_str:gsub("<h1>", "<h2>")
	post_str = post_str:gsub("<%/h1>", "<%/h2>")

	return post_str, unixtime
end

local function build_posts(posts)
	local posts_per_page = 5
	local total_pages = math.ceil(#posts / posts_per_page)

	-- Process all posts first
	local processed = {}
	for _, post in ipairs(posts) do
		local content = Util.markdown(post.raw)
		local unixtime = tonumber(content:match("<h2>(%d+)</h2>"))

		-- Transformations matching original LTP logic
		content = content:gsub("<h1>", "<header><a href=\"" .. post.url .. "\"><h2>")
			 :gsub("</h1>", "</h2></a></header>")
			 :gsub("<h2>%d+</h2>",
				 "<time datetime=\"" .. os.date("!%Y-%m-%dT%TZ", unixtime) .. "\">" .. format_date(unixtime) .. "</time>")

		table.insert(processed, {
			content = content,
			unixtime = unixtime
		})
	end

	-- Sort by timestamp descending
	table.sort(processed, function(a, b) return a.unixtime > b.unixtime end)

	-- Generate pages
	local pages = {}


	return pages
end

return function(site)
	local posts = site.collections.posts
	local posts_contents = build_posts(posts)
	return [[
		<body>
			<section id="site-nav">
				<nav>
					<a href="/blog/" id="hero" class="box button">/blog/</a>
					<a href="/" class="box button">Back to Moon Lemon</a>
				</nav>
			</section>
			<main>
				<section id="posts">
		]] .. out .. [[
				</section>
			</main>
		</body>
	]]
end
