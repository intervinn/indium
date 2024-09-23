local Indium = require("../..")

local app = Indium.App.new()

app.router:use(Indium.Middleware.Logger.new())
app.router:use(Indium.Middleware.CORS.new({
    origin = "*"
}))

app:listen(8080, function()
    print("up")
end)