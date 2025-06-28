local function format_date(unixtime)
	local days = { "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" }
	local months = { "January", "February", "March", "April", "May", "June", "July", "August", "September", "October",
		"November", "December" }
	local t = os.date("!*t", unixtime)
	return days[t.wday] .. ", " .. t.day .. " " .. months[t.month] .. " " .. t.year
end

return function(site)
	local out = "<!DOCTYPE html>"
	out = out .. site.templates.head({ title = "Blog", style = "style.css" })

	out = out .. [[
        <body>
            <section id="site-nav">
                <nav>
                    <a href="/blog/" id="hero" class="box button">/blog/</a>
                    <a href="/" class="box button">Back to kwikle.me</a>
                </nav>
            </section>
            <main>
                <section id="posts">
    ]]

	local posts = site.collections.blog or {}
	local processed = {}

	-- Process all posts to extract timestamps
	for _, post in ipairs(posts) do
		local content = Util.markdown(post.raw)
		local unixtime = tonumber(content:match("<h2>(%d+)</h2>"))

		if unixtime then
			-- Transformations for index view
			content = content:gsub("<h1>", "<header><a href=\"" .. post.url .. "\"><h2>")
				 :gsub("</h1>", "</h2></a>")
				 :gsub("<h2>" .. unixtime .. "</h2>",
					 "<time datetime=\"" .. os.date("!%Y-%m-%dT%TZ", unixtime) .. "\">" ..
					 format_date(unixtime) .. "</time></header>")
				 :gsub("<h1>", "<h2>") -- Convert any remaining h1 to h2
				 :gsub("</h1>", "</h2>")

			table.insert(processed, {
				content = '<article class="blog-post">' .. content .. '</article>',
				unixtime = unixtime
			})
		end
	end

	-- Sort by timestamp descending
	table.sort(processed, function(a, b) return a.unixtime > b.unixtime end)

	-- Pagination logic
	local posts_per_page = 5
	local total_pages = math.ceil(#processed / posts_per_page)
	local current_page = 1

	-- Get page number from query string (simulated)
	local page_param = site.page_params and site.page_params.p
	if page_param and tonumber(page_param) then
		current_page = math.min(tonumber(page_param), total_pages)
	end

	-- Calculate post range for current page
	local start_index = (current_page - 1) * posts_per_page + 1
	local end_index = math.min(current_page * posts_per_page, #processed)

	-- Render posts for current page
	for i = start_index, end_index do
		out = out .. processed[i].content
	end

	-- Pagination navigation
	out = out .. [[<nav id='page-nav'>]]
	for i = 1, total_pages do
		if i == current_page then
			out = out .. "<span>" .. i .. "</span>"
		else
			-- For static generation, use /blog/pageX.html instead of ?p=X
			local page_url = (i == 1) and "/blog/" or ("/blog/page" .. i .. ".html")
			out = out .. "<a href='" .. page_url .. "'>" .. i .. "</a>"
		end
	end
	out = out .. "</nav>"

	out = out .. [[
                </section>
            </main>
        </body>
    </html>
    ]]

	return out
end
