local Indium = require("Package")

local app = Indium.App.new()

app.router:get("/", function(req, res)
	res:status(200):json({
		message = "hello, world",
	})
end)

app:listen(8080, function()
	print(`listening on http://localhost:8080/`)
end)
