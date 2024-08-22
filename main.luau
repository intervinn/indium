local Indium = require(".")

local app = Indium.App.new()

-- middleware
app.router:use(Indium.Middleware.CORS.new({
    origin = "*"
}))
-- dynamic routing
app.router:get("/users/:user", function(req, res)  
    print(req.params)
    res:status(200):json({
        message = `hello, {req.params["user"]}`
    })
end)

-- routing
app.router:get("/", function(req, res)  
    res:status(200):json({
        message = "hello, world"
    })
end)

-- serving
app:listen(8080, function()  
    print("up")
end)