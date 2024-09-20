local handler = require("@core/handler")
local iter = require("@util/iter")

type Impl = {
    __index: Impl,
    new: (opts: CORSOptions) -> handler.Middleware
}

export type CORSOptions = {
    origin: string | {string} | (...any) -> any,
    allowMethods: {string}?,
    allowHeaders: {string}?,
    maxAge: number?,
    credentials: boolean?,
    exposeHeaders: {string}?
}

local CORS : Impl = {} :: Impl
CORS.__index = CORS
export type CORS = typeof(setmetatable({}, {} :: Impl))

function CORS.new(opts: CORSOptions): handler.Middleware
    local defaults: CORSOptions = {
        origin = "*",
        allowMethods = {"GET", "HEAD", "PUT", "POST", "DELETE", "PATCH"},
        allowHeaders = {},
        exposeHeaders = {}
    }

    for k,v in opts do
        defaults[k] = v
    end

    local findAllowOrigin = (function(optsOrigin: any): any
        if typeof(optsOrigin) == "string" then
            return function()
                return optsOrigin
            end
        elseif typeof(optsOrigin) == "function" then
            return optsOrigin
        else
            return function(origin)
                if table.find(optsOrigin, origin) then
                    return origin
                else
                    return optsOrigin[1]
                end
            end
        end
    end)(opts.origin)

    return function(req,res,next)
        local allowOrigin = findAllowOrigin(req:get("origin") or "")
        if allowOrigin then
            res:set("Access-Control-Allow-Origin", allowOrigin)
        end

        if opts.origin ~= "*" then
            local existingVary = req:get("Vary")

            if existingVary then
                res:set("Vary", existingVary)
            else
                res:set("Vary", "Origin")
            end
        end

        if opts.credentials then
            res:set("Access-Control-Allow-Credentials", "true")
        end

        if opts.exposeHeaders and #opts.exposeHeaders > 0 then
            res:set("Access-Control-Expose-Headers", table.concat(opts.exposeHeaders, ","))
        end

        if req.method == "OPTIONS" then
            if opts.maxAge then
                res:set("Access-Control-Max-Age", tostring(opts.maxAge))
            end

            if opts.allowMethods and #opts.allowMethods > 0 then
                res:set("Access-Control-Allow-Methods", table.concat(opts.allowMethods, ","))
            end

            local headers = opts.allowHeaders or {} -- lsp is so mean
            if headers and #headers > 0 then
                local reqHeaders = req:get("Access-Control-Request-Headers")

                if reqHeaders then
                    headers = iter.pack(reqHeaders:gmatch("\s*,\s*"))
                end
            end

            if #headers > 0 then
                res:set("Access-Control-Allow-Headers", table.concat(headers, ","))
                res:set("Vary", "Access-Control-Request-Headers")
            end

            res.headers["Content-Length"] = nil
            res.headers["Content-Type"] = nil

            res:status(204)
        end
        next()
    end
end

return CORS