A dead simple backend library inspired by [Express](https://github.com/expressjs/express) and powered by [Lune](https://lune-org.github.io/docs)

## Quick Example
```luau
local Indium = require("Package")

local app = Indium.App.new()

-- middleware
app.router:use(function(req, res, next)
    print(req.method, req.path)
    next()
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
```

# State of Indium
Mostly this is a practice project, and the base code was written during a random rush of motivation. In order to become a solid project it is yet to be fully documented, and some implementations are to be reconsidered.

Many inspiration on code structuring was taken from [DiscordLuau](https://github.com/DiscordLuau/discord-luau).

