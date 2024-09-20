<div>
<img align="right" src="assets/logo.svg" width="100" height="100" alt="Indium logo"/>
</div>

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
I hope I can make something big out of it, that's about it.

Many inspiration on code structuring was taken from [DiscordLuau](https://github.com/DiscordLuau/discord-luau).

