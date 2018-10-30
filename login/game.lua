
local CGlobal = CGlobal;
local CServer = CServer;
local CClient = CClient;
local CHttp = CHttp;

local g_Token = require("data.token");
local Json = require("json");

function reload(mod)
	g_Token = require("data.token");
	Json = require("json");
end 

g_RequestList = g_RequestList or {};

local _M = {};

function _M.OnSec(now)

end

function _M.OnDisconnect(iAddress)

end

return _M;