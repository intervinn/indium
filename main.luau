local Indium = require("Package")

local app = Indium.App.new()

-- middleware
app.router:use(function(req, res, next)
    print(req.method, req.path)
    next()
end)

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