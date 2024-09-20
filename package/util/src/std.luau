--[[
    we might wanna use something besides lune in the future
]]
local net = require("@lune/net")
local task = require("@lune/task")
local fs = require("@lune/fs")
local process = require("@lune/process")
local stdio = require("@lune/stdio")

local Std = table.freeze({
    net = net,
    task = task,
    fs = fs,
    process = process,
    stdio = stdio
})

export type FetchParams = net.FetchParams
export type FetchParamsOptions = net.FetchParamsOptions
export type FetchResponse = net.FetchResponse
export type HttpHeaderMap = net.HttpHeaderMap
export type HttpMethod = net.HttpMethod
export type HttpQueryMap = net.HttpQueryMap
export type ServeConfig = net.ServeConfig
export type ServeHandle = net.ServeHandle
export type ServeRequest = net.ServeRequest
export type ServeResponse = net.ServeResponse
export type WebSocket = net.WebSocket

export type Metadata = fs.Metadata
export type MetadataKind = fs.MetadataKind
export type MetadataPermission = fs.MetadataPermissions
export type WriteOptions = fs.WriteOptions

export type Arch = process.Arch
export type OS = process.OS
export type SpawnOptions = process.SpawnOptions
export type SpawnOptionsStdio = process.SpawnOptionsStdio
export type SpawnOptionsStdioKind = process.SpawnOptionsStdioKind
export type SpawnResult = process.SpawnResult

export type Color = stdio.Color
export type Style = stdio.Style

return Std