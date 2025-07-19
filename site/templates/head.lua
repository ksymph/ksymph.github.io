return function(params)
	return [[
		<head>
			<meta charset="utf-8">
			<meta name="description" content="]] .. (params.description or "The personal website of Kay Wikle") .. [[">
			<meta name="viewport" content="width=device-width, initial-scale=1">
			<title>]] .. (params.title or "Kay Wikle") .. [[</title>
			<link rel="author" href="https://kwikle.me/">]] ..
		 (params.style and [[<link rel="stylesheet" href="]] .. params.style .. [[">]] or "") .. [[
		</head>
	]]
end
