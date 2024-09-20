local handler = require("@core/handler")
local std = require("@util/std")

type Impl = {
    __index: Impl,
    new: () -> handler.Middleware
}

local Logger = {}
Logger.__index = Logger
export type Logger = typeof(setmetatable({}, {} :: Impl))

function Logger.new(): handler.Middleware
    return function(req, res, next)
        std.task.spawn(function() 
            std.stdio.write(`{req.method} - {req.path}\n`)
        end) -- stdio writes might cost you some time

        next()
    end
end

return Logger