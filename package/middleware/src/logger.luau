local handler = require("@core/handler")

type Impl = {
	__index: Impl,
	new: () -> handler.Middleware,
}

local Logger = {}
Logger.__index = Logger
export type Logger = typeof(setmetatable({}, {} :: Impl))

function Logger.new()
	return function(req, res, next)
		next()
	end
end

return Logger
