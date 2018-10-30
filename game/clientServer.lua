
local CGlobal = CGlobal;
local CServer = CServer;
local CClient = CClient;

local Config = require("config");
local Login = require("game.login");
---- local PlayerCache = require("cache.playerCache");

function reload(mod)
	Config = require("config");
	Login = require("game.login");
	---- PlayerCache = require("cache.playerCache");
end 

if not g_ClientServer then 
	print("create g_ClientServer server");
	g_ClientServer = CServer.new();
	g_ClientServer:StartListen(Config.game.client.port);
end 

function ClientServer_ON_ACCEPT(connector)
	local ip = connector:GetIP();
	local iAddress = connector:GetAddress();
	print("ClientServer_ON_ACCEPT", ip, iAddress);
	g_Client_connectors[iAddress] = {connector = connector, ip = ip, iAddress = iAddress, key = nil, rid = nil, server_id = nil, skd_id = nil, uid = nil};
end 
function ClientServer_ON_DATA(iAddress, msgId, data)
	print("ClientServer_ON_DATA", msgId);
	
	local proto = g_SprotoLoader.sessionMap[msgId];
	if not proto then 
		print("msgId " .. msgId .. " not define !!!");
		return ;
	end 
	local request_recv = g_SprotoLoader.protops:request_decode(proto, data); -- 接收请求
	if not request_recv then 
		print("data decode error !!!");
		return ;
	end 
	local logic = g_SprotoLoader.protoMap[proto].logic;
	if not logic[proto] then 
		print("function " .. proto .. " not define !!!");
		return ;
	end 
	local client = g_Client_connectors[iAddress];
	if not g_OnlineClient[client.rid] and proto ~= "LoginGame" and proto ~= "CreateRole" then 
		print("had no login first !!!");
		return ;
	end 
	local ret = logic[proto](client, request_recv);
	if ret then 
		local data = g_SprotoLoader.protops:response_encode(proto, ret);
		g_Client_connectors[iAddress].connector:Send(msgId, data, #data);
	end 
end 
function ClientServer_ON_DISCONNECT(iAddress)
	print("ClientServer_ON_DISCONNECT", iAddress);
	local rid = g_Client_connectors[iAddress].rid;
	g_Client_connectors[iAddress] = nil;
	-- 触发掉线
	xpcall(function() Login.OnDisconnect(rid); end, function (err)
		print(err); print( debug.traceback() );
	end)
	---- PlayerCache.SavePlayer(rid); 由缓存管理自己保存清除
end 

g_ClientServer:RegCallBack(CGlobal.STATIC_ON_ACCEPT, "ClientServer_ON_ACCEPT");
g_ClientServer:RegCallBack(CGlobal.STATIC_ON_DATA, "ClientServer_ON_DATA");
g_ClientServer:RegCallBack(CGlobal.STATIC_ON_DISCONNECT, "ClientServer_ON_DISCONNECT");
