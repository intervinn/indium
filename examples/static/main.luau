local Indium = require("../..")

local app = Indium.App.new()
app.router:use(Indium.Middleware.Static.new("./stuff"))

app.router:get("/", function(req, res)
	res:status(Indium.Status.OK):json({
		message = "holla",
	})
end)

app:listen(8080, function()
	print("server is up")
end)
