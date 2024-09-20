local handler = require("@core/handler")
local std = require("@util/std")

type Impl = {
    __index: Impl,
    new: (dir: string) -> handler.Middleware
}

local Static: Impl = {} :: Impl
Static.__index = Static
export type Static = typeof(setmetatable({}, {} :: Impl))

function Static.new(dir: string): handler.Middleware
    return function(req, res, next)
        next()
        local ok, body = pcall(std.fs.readFile, dir..req.path)
        if not ok then next() end
        
        res:set("Content-Type", "text/html")
        res.body = body
    end
end

return Static