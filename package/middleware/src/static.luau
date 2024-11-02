local handler = require("@core/handler")
local fs = require("@lune/fs")

type Impl = {
	__index: Impl,
	new: (dir: string) -> handler.Middleware,
}

local Static: Impl = {} :: Impl
Static.__index = Static
export type Static = typeof(setmetatable({}, {} :: Impl))

function Static.new(dir: string): handler.Middleware
	return function(req, res, next)
		next()
		local ok, body = pcall(fs.readFile, dir .. req.path)
		if not ok then
			return
		end

		res:set("Content-Type", "text/html")
		res.body = body :: string
	end
end

return Static
