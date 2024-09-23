local handler = require("@core/handler")
local datetime = require("@lune/datetime")
local stdio = require("@lune/stdio")

type Impl = {
	__index: Impl,
	new: (func: ((string) -> ())?) -> handler.Middleware,
}

local Logger: Impl = {} :: Impl
Logger.__index = Logger
export type Logger = typeof(setmetatable({}, {} :: Impl))

function Logger.new(func)
	return function(req, res, next)
		next()
		local time = datetime.now():formatLocalTime("%H-%M-%S")
		local out: (string) -> () = func or stdio.write
		out(`{time} > {req.method} {req.path} - {res.code}\n`)
	end
end

return Logger
