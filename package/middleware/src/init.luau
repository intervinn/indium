local cors = require("@middleware/cors")
local static = require("@middleware/static")
local logger = require("@middleware/logger")

local middleware = {}
middleware.CORS = cors
middleware.Static = static
middleware.Logger = logger

export type CORS = cors.CORS
export type CORSOptions = cors.CORS

export type Static = static.Static
export type Logger = logger.Logger

return middleware