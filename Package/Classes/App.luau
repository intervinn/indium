local Router = require("@Classes/Router")
local Response = require("@Classes/Response")
local Request = require("@Classes/Request")

local net = require("@lune/net")

type Impl = {
	__index: Impl,
	new: () -> App,
	listen: (self: App, port: number, func: () -> ()?) -> (),
	stop: (self: App) -> (),
}

type Proto = {
	router: Router.Router,
	handle: net.ServeHandle,
}

local App: Impl = {} :: Impl
App.__index = App
export type App = typeof(setmetatable({} :: Proto, {} :: Impl))

function App.new()
	local self = setmetatable({} :: Proto, App)
	self.router = Router.new()

	return self
end

function App:listen(port: number, func: (() -> ())?)
	if func then
		func()
	end
	
	self.handle = net.serve(port, function(req: net.ServeRequest)
		local node = self.router.node:findDescendant(req.path, req.method)
		if not node or not node.handler then
			return {
				body = "route not found",
				status = 404,
				headers = {
					["Content-Type"] = "text/plain",
				},
			} :: net.ServeResponse
		end

		local request = Request.new(req)
		local response = Response.new()
		local called = false

		local handle = function()
			node.handler(request, response)
			called = true
		end

		

		return response:respond()
	end)
end

return App
