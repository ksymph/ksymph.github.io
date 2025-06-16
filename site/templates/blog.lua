return function(post)
	local parsed_post = Util.markdown(post.raw)
	--print(parsed_post)

	local title = parsed_post:match("<h1>(.-)</h1>")
	local timestamp = parsed_post:match("<h2>(.-)</h2>")
	local content = parsed_post:match("</h2>(.*)")

	-- Format the date using os.date, a good replacement for luatz here.
	local formatted_date = os.date("%A, %B %d, %Y", timestamp)

	-- The content for a single post view.
	local post_html = [[
		<article class="blog-post">
			<header>
				<a href="">
					<h2>]] .. title .. [[</h2>
				</a>
				<time datetime="]] .. os.date("!%Y-%m-%dT%TZ", timestamp) .. [[">]] .. formatted_date .. [[</time>
			</header>
			]] .. content .. [[
		</article>
	]]
 
	-- Return the post content rendered within the base layout.
	return post_html
end