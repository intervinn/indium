--!native
local handler = require("@core/handler")
local std = require("@util/std")
local iter = require("@util/iter")

type Impl = {
	__index: Impl,
	new: (params: Proto) -> Node,
	findDescendant: (self: Node, route: string, method: std.HttpMethod?) -> (Node?, { [string]: string }),
	findChild: (self: Node, route: string, method: std.HttpMethod?) -> Node?,
	add: (
		self: Node,
		route: string,
		handler: handler.Handler,
		method: std.HttpMethod,
		middleware: { handler.Middleware }
	) -> (),
}

type Proto = {
	method: std.HttpMethod?,
	handler: handler.Handler?,
	route: string?,
	children: { Node },
	middleware: { handler.Middleware },
	dynamic: boolean,
}

local Node: Impl = {} :: Impl
Node.__index = Node

export type Node = typeof(setmetatable({} :: Proto, {} :: Impl))

function Node.new(params: Proto)
	local self = setmetatable(params :: Proto, Node)

	return self
end

function Node:findChild(route: string, method: std.HttpMethod?): Node?
	for _, v in self.children do
		if method and v.method and method ~= v.method then
			continue
		end

		if v.route == route then
			return v
		end
	end

	--[[ 
		if no static routes available..
		search for first available dynamic route
	]]

	for _, v in self.children do
		if not v.route then
			continue
		end

		if v.dynamic then
			if method and v.method and method ~= v.method then
				continue
			end
			return v
		end
	end

	return nil
end

function Node:findDescendant(route: string, method: std.HttpMethod?): (Node?, { [string]: string })
	local parent: Node = self :: Node
	local child: Node?
	local params = {}

	for str in route:gmatch("([^/]+)") do
		child = parent:findChild(str, method)

		if child then
			parent = child
			child = nil
		else
			return nil, {}
		end

		if parent.dynamic and parent.route then
			params[parent.route:sub(2)] = str
		end
	end

	return parent, params
end

function Node:add(route: string, handler: handler.Handler, method: std.HttpMethod, middleware: { handler.Middleware })
	local scope = self
	local pieces = iter.pack(route:gmatch("([^/]+)"))

	if #pieces == 0 then
		self.method = method
		self.handler = handler
		self.middleware = middleware
		return
	end

	for i, v in pieces do
		if not v then continue end
		local isdynamic = v:sub(1, 1) == ":"

		if i == #pieces then
			table.insert(
				scope.children,
				Node.new({
					route = v,
					handler = handler,
					middleware = middleware,
					children = {},
					dynamic = isdynamic,
					method = method
				})
			)
			return
		end

		local node = scope:findChild(v) :: any
		if not node then
			node = Node.new({
				route = v,
				dynamic = isdynamic,
				children = {},
				middleware = middleware,
			})
			table.insert(scope.children, node)
		end
		scope = node
	end
end

return Node
