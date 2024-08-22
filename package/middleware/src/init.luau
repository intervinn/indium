local cors = require("@middleware/cors")

local middleware = {}
middleware.CORS = cors

export type CORS = cors.CORS
export type CORSOptions = cors.CORS

return middleware