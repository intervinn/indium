--!native
local handler = require("@core/handler")
local Node = require("@core/node")
local std = require("@util/std")

type Impl = {
	__index: Impl,
	new: () -> Router,

	route: (self: Router, route: string, handler: handler.Handler, method: std.HttpMethod) -> (),

	post: (self: Router, route: string, handler: handler.Handler) -> (),
	get: (self: Router, route: string, handler: handler.Handler) -> (),
	head: (self: Router, route: string, handler: handler.Handler) -> (),
	options: (self: Router, route: string, handler: handler.Handler) -> (),
	patch: (self: Router, route: string, handler: handler.Handler) -> (),
	put: (self: Router, route: string, handler: handler.Handler) -> (),

	use: (self: Router, func: handler.Middleware) -> (),
	mount: (self: Router, router: Router, prefix: string) -> ()
}

type Proto = {
	node: Node.Node,
	middleware: {handler.Middleware}
}

local Router: Impl = {} :: Impl
Router.__index = Router

export type Router = typeof(setmetatable({} :: Proto, {} :: Impl))

function Router.new()
	local self = setmetatable({} :: Proto, Router)
	self.node = Node.new({
		children = {},
		dynamic = false,
		middleware = {}
	})
	self.middleware = {}
	return self
end

function Router:route(route: string, handler: handler.Handler, method: std.HttpMethod)
	self.node:add(route, handler, method, self.middleware)
end

function Router:get(route: string, handler: handler.Handler)
	self:route(route, handler, "GET")
end

function Router:head(route: string, handler: handler.Handler)
	self:route(route, handler, "HEAD")
end

function Router:options(route: string, handler: handler.Handler)
	self:route(route, handler, "OPTIONS")
end

function Router:patch(route: string, handler: handler.Handler)
	self:route(route, handler, "PATCH")
end

function Router:put(route: string, handler: handler.Handler)
	self:route(route, handler, "PUT")
end

function Router:use(func: handler.Middleware)
	table.insert(self.middleware, func)
end

function Router:mount(other: Router, prefix: string)
	other.node.route = prefix
	table.insert(self.node.children, other.node)
end

return Router
