type Impl = {
	__index: Impl,
	pack: <T>(iter: () -> ...T) -> { T },
}

local Iter: Impl = {} :: Impl
Iter.__index = Iter

function Iter.pack<T>(iter: () -> ...T): { T }
	local res = table.create(0)
	for i in iter do
		table.insert(res, i)
	end
	return res
end

return Iter
