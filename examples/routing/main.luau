local Indium = require("../..")

local users = Indium.Router.new()
users:get("/:username", function(req, res)
    res:status(200):json({
        message = `you might be looking for {req.params.username}`
    })
end)

local app = Indium.App.new()
app.router:use(Indium.Middleware.Logger.new())


app.router:mount(users, "/users")


app.router:get("/", function(req, res)
    res:status(200):json({
        message = "hello, world"
    })
end)

app:listen(8080, function()
    print("up")
end)