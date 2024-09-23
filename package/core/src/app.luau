--!native
local router = require("@core/router")
local response = require("@core/response")
local request = require("@core/request")
local handler = require("@core/handler")

local net = require("@lune/net")
local task = require("@lune/task")
local stdio = require("@lune/stdio")

local status = require("@enum/status")

type Impl = {
	__index: Impl,
	new: () -> App,
	listen: (self: App, port: number, func: () -> ()?) -> (),
	stop: (self: App) -> (),
}

type Proto = {
	router: router.Router,
	handle: net.ServeHandle,
}

local App: Impl = {} :: Impl
App.__index = App

export type App = typeof(setmetatable({} :: Proto, {} :: Impl))

function App.new()
	local self = setmetatable({} :: Proto, App)
	self.router = router.new()
	return self
end

function App:listen(port, func)
	local function onRequest(req: net.ServeRequest)
		local handle: handler.Handler = function(req, res)
			res:text("route not found")
			res:status(status.NOT_FOUND)
		end
		local middleware = self.router.middleware

		local node, params = self.router.node:findDescendant(req.path, req.method)
		if node and node.handler then
			handle = node.handler
		end
		if node and node.middleware then
			middleware = node.middleware
		end

		local request = request.new({
			body = req.body,
			method = req.method,
			path = req.path,
			query = req.query,
			headers = req.headers,
			params = params,
		})
		local response = response.new()

		local stack = table.clone(middleware) :: { any }
		table.insert(stack, handle)
		local current = 1

		local function nextFunction()
			if current == #stack then
				return
			end
			current += 1
			stack[current](request, response, nextFunction)
		end

		stack[current](request, response, nextFunction)
		return response:respond()
	end

	-- some things we might wanna do after the server starts up
	task.defer(function()
		if func then
			func()
		end
	end)
	print(string.char(27,91), "---")
	print(("\x1b[35mThank you for using Indium!\nport: %d\x1b[0m"):format(port))
	-- now we serve
	self.handle = net.serve(port, onRequest)
end

return App
