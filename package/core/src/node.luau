--!native
local handler = require("@core/handler")
local iter = require("@util/iter")
local net = require("@lune/net")

type Impl = {
	__index: Impl,
	new: (params: Proto) -> Node,
	findDescendant: (self: Node, route: string, method: net.HttpMethod?) -> (Node?, { [string]: string }),
	findChild: (self: Node, route: string, method: net.HttpMethod?) -> Node?,
	add: (
		self: Node,
		route: string,
		handler: handler.Handler,
		method: net.HttpMethod,
		middleware: { handler.Middleware }
	) -> (),
}

type Proto = {
	method: net.HttpMethod?,
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

function Node:findChild(route, method)
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

function Node:findDescendant(route, method)
	local parent: Node = self :: Node
	local child: Node?
	local params = {}

	for _,v in route:split("/") do
		if #v == 0 then continue end
		child = parent:findChild(v, method :: net.HttpMethod)

		if child then
			parent = child
			child = nil
		else
			return nil, {}
		end

		if parent.dynamic and parent.route then
			params[parent.route:sub(2)] = v
		end
	end

	return parent, params
end

function Node:add(route, handler, method, middleware)
	local scope = self
	local pieces = route:split("/")
	local len = #pieces

	if #pieces == 0 then
		self.method = method :: net.HttpMethod
		self.handler = handler
		self.middleware = middleware
		return
	end

	for i = 1, len-1 do
		local v = pieces[i]
		if v == "" then continue end

		local isdynamic = v:sub(1, 1) == ":"
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
	table.insert(
		scope.children,
		Node.new({
			route = pieces[len],
			handler = handler,
			middleware = middleware,
			children = {},
			dynamic = pieces[len]:sub(1,1) == ":",
			method = method :: net.HttpMethod
		})
	)
end

return Node
