local router = require("@core/router")
local response = require("@core/response")
local request = require("@core/request")

local net = require("@lune/net")
local task = require("@lune/task")

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

function App:listen(port: number, func: (() -> ())?)
	task.defer(function()
		if func then
			func()
		end
	end)
	
	self.handle = net.serve(port, function(req: net.ServeRequest)
		local node, params = self.router.node:findDescendant(req.path, req.method)
		if not node or not node.handler then
			return {
				body = "route not found",
				status = 404,
				headers = {
					["Content-Type"] = "text/plain",
				},
			} :: net.ServeResponse
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

		local stack = table.clone(node.middleware)

		local index = 1
		local function nextFunction()
			if index == #stack then return end
			index += 1
			stack[index](request, response, nextFunction)
		end

		local function handle(req,res,next)
			node.handler(req, res)
			next()
		end
		table.insert(stack, handle)
		stack[index](request, response, nextFunction)

		return response:respond()
	end)
end

return App
