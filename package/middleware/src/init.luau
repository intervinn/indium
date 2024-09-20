local cors = require("@middleware/cors")
local static = require("@middleware/static")

local middleware = {}
middleware.CORS = cors
middleware.Static = static

export type CORS = cors.CORS
export type CORSOptions = cors.CORS

export type Static = static.Static

return middleware