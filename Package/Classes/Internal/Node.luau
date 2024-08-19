local Handler = require("../Objects/Handler")
local net = require("@lune/net")

type Impl = {
	__index: Impl,
	new: (route: string?, handler: Handler.Handler?, method: net.HttpMethod?) -> Node,
	findDescendant: (self: Node, route: string, method: net.HttpMethod?) -> Node?,
	findChild: (self: Node, route: string, method: net.HttpMethod?) -> Node?,
	add: (self: Node, route: string, handler: Handler.Handler, method: net.HttpMethod) -> (),
}

type Proto = {
	method: net.HttpMethod?,
	handler: Handler.Handler?,
	route: string,
	children: { Node },
}

local Node: Impl = {} :: Impl
Node.__index = Node

export type Node = typeof(setmetatable({} :: Proto, {} :: Impl))

function Node.new(route: string?, handler: Handler.Handler?, method: net.HttpMethod?)
	local self = setmetatable({} :: Proto, Node)
	self.children = {}
	self.handler = handler
	self.method = method
	self.route = route

	return self
end

function Node:findChild(route: string, method: net.HttpMethod?): Node?
	for _, v in self.children do
		if v.route == route then
			if method and v.method and method ~= v.method then
				continue
			end
			return v
		end
	end
	return nil
end

function Node:findDescendant(route: string, method: net.HttpMethod?): Node?
	local res: Node = self :: Node
	local tmp: Node?

	for str in route:gmatch("([^/]+)") do
		tmp = res:findChild(str, method)
		if tmp then
			res = tmp
			tmp = nil
		else
			return nil
		end
	end
	return res
end

function Node:add(route: string, handler: Handler.Handler, method: net.HttpMethod)
	local scope: Node = self
	local pieces = {} :: { string }
	for str in route:gmatch("([^/]+)") do
		table.insert(pieces, str)
	end

	if #pieces == 0 then
		self.method = method
		self.handler = handler
		return
	end

	for i, v in pieces do
		if i == #pieces then
			table.insert(scope.children, Node.new(v, handler, method))
			return
		end

		local node = scope:findChild(v)
		if not node then
			node = Node.new(v)
			table.insert(scope.children, node)
		end
		scope = node
	end
end

return Node
